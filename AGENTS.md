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
### Stack
- Backend: PowerShell 脚本仓库，面向 Windows PowerShell / PowerShell CLI 运行；核心逻辑使用 `Set-StrictMode`、参数块、交互式 `Read-Host`、`.NET` 文件 API、目录创建、UTF-8 无 BOM 写入与备份覆盖策略。
- Frontend: 无；仓库不包含 Web UI、桌面 UI 或前端静态资源。
- Database: 无；不使用数据库，状态仅保存在本地文件、Git 工作区以及生成的 `.bak.<timestamp>` 备份文件中。
- Cache / MQ / Infra: 本地文件系统、Git 仓库、`$env:USERPROFILE\\.codex`、`$env:USERPROFILE\\.agents\\skills\\harness-session`，以及 PowerShell 宿主环境本身。

### Important Paths
- Core app: `install-harness.ps1`，包含交互安装流程、全局/项目级 `AGENTS.md` 模板、`harness-session` skill 模板，以及项目文档骨架初始化逻辑。
- Tests: 当前仓库没有自动化测试目录；最相关验证是对 `install-harness.ps1` 做 PowerShell 语法解析检查，必要时补充 `Invoke-ScriptAnalyzer` 静态检查。
- Config: `AGENTS.md`；脚本还会写入 `$env:USERPROFILE\\.codex\\AGENTS.md`、`$env:USERPROFILE\\.agents\\skills\\harness-session\\SKILL.md`，并按参数或交互结果更新目标项目下的 `AGENTS.md`。
- Docs: `MISSION.md`、`plans/active/current.md`、`docs/README.md`、`docs/constraints.md`、`docs/system_map.md`、`docs/runbook.md`、`reports/run_log.md`、`memory/lessons.md`、`memory/decisions.md`；这些文件由安装脚本初始化为仓库级文档骨架。

### Common Commands
- Install: `powershell -ExecutionPolicy Bypass -File .\\install-harness.ps1`
- Dev: `powershell -ExecutionPolicy Bypass -File .\\install-harness.ps1 -RepoRoot .`
- Test: `powershell -NoProfile -Command "$tokens=$null;$errors=$null;[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path '.\\install-harness.ps1'),[ref]$tokens,[ref]$errors) | Out-Null; if ($errors) { $errors | Out-String | Write-Error; exit 1 }"`
- Lint: 若本机已安装 PSScriptAnalyzer，可运行 `powershell -NoProfile -Command "Invoke-ScriptAnalyzer -Path .\\install-harness.ps1"`
- Build: 无；脚本型仓库，不存在编译或打包步骤。

### High-Risk Areas
- 已存在文件的覆盖、追加与备份逻辑：`AGENTS.md`、`SKILL.md` 和初始化文档都可能被直接改写；一旦目标路径或写入模式判断错误，会影响用户现有规范文件。
- `Read-RepoRoot` 与安装目标路径解析：`-RepoRoot`、当前目录选择和手工输入共同决定写入位置，传错后会把模板落到错误仓库或错误目录。
- 用户目录下的全局安装副作用：`$env:USERPROFILE\\.codex` 与 `$env:USERPROFILE\\.agents` 的写入会影响后续所有 Codex session，不只是当前仓库。
