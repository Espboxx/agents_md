param(
    [string]$RepoRoot = "",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:UseCurrentProjectRoot = $false

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )

    if ($script:Force) {
        return $true
    }

    while ($true) {
        $suffix = if ($Default) { "[是(Y)/否(n)]" } else { "[是(y)/否(N)]" }
        $answer = Read-Host "$Prompt $suffix"

        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $Default
        }

        switch ($answer.Trim().ToLowerInvariant()) {
            "y" { return $true }
            "yes" { return $true }
            "是" { return $true }
            "n" { return $false }
            "no" { return $false }
            "否" { return $false }
            default { Write-Host "请输入 y 或 n。" }
        }
    }
}

function Read-RepoRoot {
    param([string]$InitialValue)

    if ($InitialValue -and $InitialValue.Trim().Length -gt 0) {
        $script:UseCurrentProjectRoot = $false
        return [System.IO.Path]::GetFullPath($InitialValue)
    }

    if ($script:Force) {
        $script:UseCurrentProjectRoot = $false
        return ""
    }

    $useCurrentProject = Read-YesNo -Prompt "是否将项目 AGENTS.md 安装到当前项目目录？`n$PWD" -Default $true
    if ($useCurrentProject) {
        $script:UseCurrentProjectRoot = $true
        return [System.IO.Path]::GetFullPath($PWD.Path)
    }

    $script:UseCurrentProjectRoot = $false
    $answer = Read-Host "请输入项目根目录（留空则跳过项目 AGENTS.md 安装）"
    if ([string]::IsNullOrWhiteSpace($answer)) {
        return ""
    }

    return [System.IO.Path]::GetFullPath($answer.Trim())
}

function Read-AppendOrOverwrite {
    param([string]$Path)

    if ($script:Force) {
        return "overwrite"
    }

    while ($true) {
        $answer = Read-Host "当前目录已存在 AGENTS.md，选择写入方式：追加(a) / 覆盖(o)`n$Path [a/o]"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return "append"
        }

        switch ($answer.Trim().ToLowerInvariant()) {
            "a" { return "append" }
            "append" { return "append" }
            "追加" { return "append" }
            "o" { return "overwrite" }
            "overwrite" { return "overwrite" }
            "覆盖" { return "overwrite" }
            default { Write-Host "请输入 a 或 o。" }
        }
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Write-FileWithBackup {
    param(
        [string]$Path,
        [string]$Content,
        [switch]$ForceOverwrite
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }

    $shouldWrite = $true

    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
        if ($existing -eq $Content) {
            Write-Host "[SKIP] Unchanged: $Path"
            $shouldWrite = $false
        }
        else {
            if (-not $ForceOverwrite) {
                $confirmed = Read-YesNo -Prompt "文件已存在，是否覆盖？`n$Path" -Default $true
                if (-not $confirmed) {
                    Write-Host "[SKIP] Keep existing: $Path"
                    $shouldWrite = $false
                }
            }

            if (-not $shouldWrite) {
                return
            }

            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backup = "$Path.bak.$timestamp"
            Copy-Item -LiteralPath $Path -Destination $backup -Force
            Write-Host "[BACKUP] $backup"
            Write-Host "[INFO] Overwriting existing file: $Path"
        }
    }

    if ($shouldWrite) {
        Write-Utf8File -Path $Path -Content $Content
        Write-Host "[WRITE] $Path"
    }
}

function Append-FileWithBackup {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }

    $existing = ""
    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "$Path.bak.$timestamp"
        Copy-Item -LiteralPath $Path -Destination $backup -Force
        Write-Host "[BACKUP] $backup"
    }

    $separator = if ([string]::IsNullOrWhiteSpace($existing)) { "" } else { "`r`n`r`n" }
    Write-Utf8File -Path $Path -Content ($existing + $separator + $Content)
    Write-Host "[APPEND] $Path"
}

function Initialize-ProjectDocuments {
    param(
        [string]$RepoRoot,
        [System.Collections.Generic.List[string]]$InstalledTargets
    )

    $docItems = @(
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "MISSION.md"
            Content = @'
# Mission

## 项目目标
- 用一句话说明这个项目要解决什么问题。

## 交付范围
- 当前要交付的核心能力：
- 明确不包含的内容：

## 成功标准
- 功能完成的判断标准：
- 验证方式：

## 当前阶段
- 当前阶段：
- 当前优先级：
- 当前主要风险：
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "plans\active\current.md"
            Content = @'
# Current Plan

## Objective
- 当前正在完成的目标：

## Known Facts
- 已确认事实：

## Unknowns / Blockers
- 未知项：
- 阻塞项：

## Next Small Step
- 下一步最小动作：

## Validation
- 计划采用的验证方式：

## Progress Log
- YYYY-MM-DD HH:mm: 初始化计划文档。
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "docs\README.md"
            Content = @'
# Docs README

本文档目录用于沉淀当前项目的长期有效信息，避免关键信息只存在于临时对话中。

## 建议阅读顺序
1. `MISSION.md`
2. `AGENTS.md`
3. `plans/active/current.md`
4. `docs/constraints.md`
5. `docs/system_map.md`
6. `docs/runbook.md`

## 文档职责
- `constraints.md`：项目约束、边界、兼容性要求、禁止事项。
- `system_map.md`：模块结构、目录职责、关键依赖与主要数据流。
- `runbook.md`：常用操作、验证方式、排障步骤、发布或回滚要点。
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "docs\constraints.md"
            Content = @'
# Constraints

## 技术约束
- 运行环境：
- 语言 / 版本：
- 依赖限制：

## 业务约束
- 业务边界：
- 合规或审计要求：

## 工程约束
- 不允许的改动类型：
- 必须保留的兼容性：
- 性能 / 安全 / 稳定性要求：

## 交付约束
- 时间约束：
- 验收约束：
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "docs\system_map.md"
            Content = @'
# System Map

## 顶层结构
- 入口：
- 核心模块：
- 配置文件：
- 测试位置：

## 目录职责
- `{{PATH_1}}`：
- `{{PATH_2}}`：
- `{{PATH_3}}`：

## 关键流程
1. 输入从哪里进入：
2. 核心处理在哪里发生：
3. 输出写到哪里：

## 风险热点
- 易出错模块：
- 高耦合区域：
- 需要谨慎修改的路径：
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "docs\runbook.md"
            Content = @'
# Runbook

## 常用命令
- 安装：
- 开发：
- 测试：
- 构建：

## 最小验证清单
- 修改后先执行：
- 必看输出：
- 成功判定：

## 常见问题排查
- 问题现象：
- 排查步骤：
- 解决方式：

## 变更注意事项
- 高风险操作：
- 回滚方式：
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "reports\run_log.md"
            Content = @'
# Run Log

- YYYY-MM-DD HH:mm: 初始化项目运行日志文档。
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "memory\lessons.md"
            Content = @'
# Lessons

- 记录经过验证、值得长期保留的经验。
'@
        },
        [pscustomobject]@{
            Path = Join-Path $RepoRoot "memory\decisions.md"
            Content = @'
# Decisions

- 记录已经做出的关键决策、原因与影响范围。
'@
        }
    )

    Write-Host ""
    Write-Host "== 初始化项目文档 =="

    foreach ($docItem in $docItems) {
        Write-FileWithBackup -Path $docItem.Path -Content $docItem.Content -ForceOverwrite:$Force
        if (-not $InstalledTargets.Contains($docItem.Path)) {
            $InstalledTargets.Add($docItem.Path) | Out-Null
        }
    }
}

$UserHome = $env:USERPROFILE
if (-not $UserHome) {
    throw "无法解析 USERPROFILE。"
}

$GlobalCodexDir   = Join-Path $UserHome ".codex"
$GlobalAgentsDir  = Join-Path $UserHome ".agents"
$SkillDir         = Join-Path $GlobalAgentsDir "skills\harness-session"
$SkillFile        = Join-Path $SkillDir "SKILL.md"
$GlobalAgentsFile = Join-Path $GlobalCodexDir "AGENTS.md"
$InstalledProjectAgentsFile = ""
$InitializedProjectDocs = $false

$SkillContent = @'
---
name: harness-session
description: Use this skill at the start of any coding or repo session that requires structured planning, step-by-step execution, verification, durable write-back, or long-running task continuity. Trigger for implementation, debugging, refactoring, feature work, documentation maintenance, or any task that spans multiple steps. Do not use for trivial one-shot questions with no repo interaction.
---

# Harness Session Skill

## Goal
Apply a consistent harness workflow so work is:
- planned before execution
- executed in the smallest valuable step
- verified before being claimed complete
- written back into durable repo artifacts when appropriate

## Mandatory Session Bootstrap
At the beginning of a session:

1. Read the closest applicable instruction sources in this order:
   - global AGENTS guidance already injected by Codex
   - repository `AGENTS.md`
   - `MISSION.md` if present
   - `plans/active/current.md` if present
   - `docs/README.md`, `docs/constraints.md`, `docs/system_map.md`, `docs/runbook.md` if present
   - task-relevant source code, tests, configs, logs

2. Identify:
   - current objective
   - known facts
   - unknowns / blockers
   - smallest next action
   - validation method

3. Before making substantial changes, create or update the working plan:
   - if `plans/active/current.md` exists, update it
   - otherwise keep a concise plan in the response

## Execution Loop
For each cycle:

1. Read only what is necessary for the current step.
2. Choose one minimal, high-value, verifiable action.
3. Execute the action.
4. Validate using the most relevant checks:
   - tests
   - lint / typecheck
   - build
   - minimal runtime/manual validation
   - logs / diff / sample output
5. Do not claim completion without evidence.
6. Summarize:
   - what changed
   - why
   - evidence
   - risks
   - next step

## Durable Write-Back
When these files exist, update them as needed:
- `plans/active/current.md`
- `reports/run_log.md`
- `memory/lessons.md`
- `memory/decisions.md`
- `docs/runbook.md`
- `docs/system_map.md`

Only write back:
- verified lessons
- durable conventions
- repeatable procedures
- real decisions with reasons

Do not write back:
- guesses
- temporary confusion
- unverified assumptions

## Failure Handling
If blocked or failing repeatedly:

1. preserve evidence
2. narrow scope
3. add logging or checks
4. revise the plan
5. stop blind retries after two failed attempts with no new evidence
6. escalate when the action is risky, irreversible, or requires human judgment

## Safety
Do not take irreversible or high-risk actions without explicit approval, including:
- deleting important data
- changing production config
- destructive schema changes
- permission changes
- external messaging
- deployment / release actions

## Preferred Response Format
Use this structure when the task is non-trivial:

STATUS:
OBJECTIVE:
READ:
PLAN:
ACTION:
EVIDENCE:
RESULT:
UPDATED_ARTIFACTS:
RISKS_OR_BLOCKERS:
NEXT_STEP:
ESCALATION:
'@

$GlobalAgentsContent = @'
# Global AGENTS.md

## Session Bootstrap Rule
At the start of every new session, always apply the `harness-session` workflow before doing any substantial work.

This is mandatory for:
- coding tasks
- debugging
- refactoring
- feature implementation
- documentation updates
- multi-step analysis inside a repository

For trivial one-shot questions with no repository interaction, keep the process lightweight.

## Required First Actions For Every Non-Trivial Session
1. Read the active project instructions and task-relevant files.
2. Establish:
   - objective
   - known facts
   - unknowns
   - next smallest step
   - validation plan
3. Follow the `harness-session` skill workflow for execution, validation, and write-back.
4. Do not claim completion without evidence.
5. If project harness files exist, update them:
   - `plans/active/current.md`
   - `reports/run_log.md`
   - `memory/lessons.md`
   - `memory/decisions.md`
   - `docs/runbook.md`
   - `docs/system_map.md`

## Working Defaults
- 默认使用中文回复，除非用户明确要求其他语言。
- 先计划，后执行。
- 一次只做一个最小但有价值的步骤。
- 优先运行与改动最相关的验证。
- 连续失败两次且没有新增证据时，不要机械重试。
- 高风险动作必须升级人工。

## Reporting
For non-trivial tasks, report with:
- STATUS
- OBJECTIVE
- READ
- PLAN
- ACTION
- EVIDENCE
- RESULT
- UPDATED_ARTIFACTS
- RISKS_OR_BLOCKERS
- NEXT_STEP
- ESCALATION
'@

$ProjectAgentsContent = @'
# Project AGENTS.md

## Repository Harness Rule
For every non-trivial session in this repository, the `harness-session` workflow is required.

## Must Read First
1. `MISSION.md`
2. `AGENTS.md`
3. `plans/active/current.md`
4. `docs/constraints.md`
5. `docs/system_map.md`
6. `docs/runbook.md`

## Repo Working Rules
- 先定位与任务直接相关的模块，再开始改动。
- 一次只做一个最小且可验证的步骤。
- 只修改与当前目标直接相关的文件。
- 保持与现有代码风格、命名风格、目录结构一致。
- 非必要不引入新依赖、不改公共接口、不做大重构。

## Repo Write-Back Rule
After meaningful work, update if present:
- `plans/active/current.md`
- `reports/run_log.md`

Update when needed:
- `memory/lessons.md`
- `memory/decisions.md`
- `docs/runbook.md`
- `docs/system_map.md`

## Validation Rule
Any code change must be followed by the most relevant validation available:
- test
- lint
- build
- runtime check
- log/sample verification

Do not claim `fixed` without evidence.

## Project-Specific Section
请由项目维护者补充以下内容：

### Stack
- Backend: {{BACKEND_STACK}}
- Frontend: {{FRONTEND_STACK}}
- Database: {{DATABASES}}
- Cache / MQ / Infra: {{INFRA}}

### Important Paths
- Core app: {{CORE_PATHS}}
- Tests: {{TEST_PATHS}}
- Config: {{CONFIG_PATHS}}
- Docs: {{DOC_PATHS}}

### Common Commands
- Install: {{INSTALL_COMMAND}}
- Dev: {{DEV_COMMAND}}
- Test: {{TEST_COMMAND}}
- Lint: {{LINT_COMMAND}}
- Build: {{BUILD_COMMAND}}

### High-Risk Areas
- {{HIGH_RISK_AREA_1}}
- {{HIGH_RISK_AREA_2}}
- {{HIGH_RISK_AREA_3}}
'@

$InstalledTargets = New-Object System.Collections.Generic.List[string]

Write-Host ""
Write-Host "== Harness 安装器 =="
Write-Host "默认会交互确认；加上 -Force 可直接覆盖。"

$InstallGlobal = Read-YesNo -Prompt "安装 / 更新全局 harness skill 和全局 AGENTS.md？" -Default $true
if ($InstallGlobal) {
    Ensure-Directory -Path $GlobalCodexDir
    Ensure-Directory -Path $SkillDir

    Write-Host ""
    Write-Host "== 安装全局 harness skill 和全局 AGENTS =="
    Write-FileWithBackup -Path $SkillFile -Content $SkillContent -ForceOverwrite:$Force
    Write-FileWithBackup -Path $GlobalAgentsFile -Content $GlobalAgentsContent -ForceOverwrite:$Force
    $InstalledTargets.Add($SkillFile) | Out-Null
    $InstalledTargets.Add($GlobalAgentsFile) | Out-Null
}
else {
    Write-Host "[SKIP] 已跳过全局安装。"
}

$ResolvedRepoRoot = Read-RepoRoot -InitialValue $RepoRoot
if ($ResolvedRepoRoot) {
    $InstallProject = Read-YesNo -Prompt "安装 / 更新项目 AGENTS.md 到：`n$ResolvedRepoRoot" -Default $true
    if ($InstallProject) {
        Ensure-Directory -Path $ResolvedRepoRoot
        $ProjectAgentsFile = Join-Path $ResolvedRepoRoot "AGENTS.md"

        Write-Host ""
        Write-Host "== 安装项目 AGENTS.md =="
        if ($script:UseCurrentProjectRoot -and (Test-Path -LiteralPath $ProjectAgentsFile) -and (-not $Force)) {
            $writeMode = Read-AppendOrOverwrite -Path $ProjectAgentsFile
            if ($writeMode -eq "append") {
                Append-FileWithBackup -Path $ProjectAgentsFile -Content $ProjectAgentsContent
            }
            else {
                Write-FileWithBackup -Path $ProjectAgentsFile -Content $ProjectAgentsContent -ForceOverwrite:$true
            }
        }
        else {
            Write-FileWithBackup -Path $ProjectAgentsFile -Content $ProjectAgentsContent -ForceOverwrite:$Force
        }
        $InstalledProjectAgentsFile = $ProjectAgentsFile
        $InstalledTargets.Add($ProjectAgentsFile) | Out-Null

        $InitializeDocs = Read-YesNo -Prompt "是否初始化项目文档骨架（MISSION / plans / docs / reports / memory）？" -Default $true
        if ($InitializeDocs) {
            Initialize-ProjectDocuments -RepoRoot $ResolvedRepoRoot -InstalledTargets $InstalledTargets
            $InitializedProjectDocs = $true
        }
        else {
            Write-Host "[SKIP] 已跳过项目文档初始化。"
        }
    }
    else {
        Write-Host "[SKIP] 已跳过项目安装：$ResolvedRepoRoot"
    }
}
else {
    Write-Host "[SKIP] 未选择项目目录。"
}

Write-Host ""
Write-Host "安装完成。"
if ($InstalledTargets.Count -gt 0) {
    Write-Host ""
    Write-Host "已创建 / 已更新："
    foreach ($target in $InstalledTargets) {
        Write-Host " - $target"
    }
}
else {
    Write-Host "[INFO] 本次未选择任何要安装的文件。"
}

Write-Host ""
Write-Host "后续步骤："
Write-Host "1) 重启 Codex / 新开一个 session"
Write-Host "2) 进入你的项目目录"
Write-Host "3) 让 Codex 先复述当前加载到的 instructions，确认 harness 已生效"
Write-Host ""
Write-Host "示例检查："
Write-Host 'codex "请总结当前已加载的 instructions，并告诉我 harness-session workflow 是否已生效。"' 

if ($InstalledProjectAgentsFile) {
    Write-Host ""
    Write-Host "填写项目模板的提示词："
    Write-Host ("codex ""请阅读当前项目并分析代码库，补全 '" + $InstalledProjectAgentsFile + "' 中 Project-Specific Section 的所有占位符，包括技术栈、重要路径、常用命令和高风险区域；直接修改文件，不要保留任何 {{...}} 模板变量。""")
}

if ($InitializedProjectDocs) {
    Write-Host ""
    Write-Host "补全文档内容的提示词："
    Write-Host ("codex ""请阅读当前项目并补全文档骨架，直接修改 '" + $ResolvedRepoRoot + "' 下的 MISSION.md、plans/active/current.md、docs/README.md、docs/constraints.md、docs/system_map.md、docs/runbook.md、reports/run_log.md、memory/lessons.md、memory/decisions.md；要求内容基于代码库事实，不要保留模板占位说明。""")
}
