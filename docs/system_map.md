# System Map

## 顶层结构
- 入口：`install-harness.ps1` 是唯一执行入口，负责整个安装与初始化流程。
- 核心模块：目录创建、交互确认、项目根解析、备份覆盖写入、追加写入、项目文档初始化都集中在同一个脚本文件内。
- 配置文件：仓库内规则由 `AGENTS.md` 管理；脚本还会写入 `$env:USERPROFILE\.codex\AGENTS.md` 和 `$env:USERPROFILE\.agents\skills\harness-session\SKILL.md`。
- 测试位置：仓库没有独立测试目录；当前最相关的校验是对 `install-harness.ps1` 做 PowerShell Parser 语法检查，必要时辅以 `Invoke-ScriptAnalyzer`。

## 目录职责
- 仓库根目录：保存 `install-harness.ps1`、当前项目的 `AGENTS.md` 和 `MISSION.md`，也是提示词默认指向的项目级落盘位置。
- `plans/active/`：保存当前会话的工作计划、已确认事实、下一步和进度日志。
- `docs/`：保存长期有效的项目约束、系统结构与操作手册。
- `reports/`：保存已完成工作的时间线记录，便于追溯最近一次有效修改。
- `memory/`：沉淀可长期复用的 lessons 和已经落地的 decisions。

## 关键流程
1. 入口接收 `-RepoRoot` 与 `-Force` 参数，启用严格模式，并准备用户目录下的全局目标路径。
2. 若用户允许安装全局内容，脚本会创建 `.codex` 与 `.agents\skills\harness-session`，然后写入 `SKILL.md` 与全局 `AGENTS.md`。
3. `Read-RepoRoot` 根据显式参数、当前目录或手工输入决定项目根目录；`-Force` 且未传 `-RepoRoot` 时会直接跳过项目安装。
4. 项目安装阶段会写入或更新项目 `AGENTS.md`；只有在“当前目录 + 已存在文件 + 非 Force”这一分支下，才会询问追加还是覆盖。
5. 若用户允许初始化文档，`Initialize-ProjectDocuments` 会批量写入 `MISSION.md`、`plans/active/current.md`、`docs/*`、`reports/run_log.md` 和 `memory/*`。
6. 所有写入都经过 `Write-FileWithBackup` 或 `Append-FileWithBackup`，最后打印已创建/更新的目标列表和后续操作提示。

## 关键函数
- `Ensure-Directory`：在写文件前确保父目录存在。
- `Read-YesNo`：封装交互式是/否确认，并在 `-Force` 下直接返回 `true`。
- `Read-RepoRoot`：决定项目根目录来源，同时控制是否视为“当前项目目录”。
- `Write-Utf8File`：统一 UTF-8 无 BOM 写入。
- `Write-FileWithBackup`：负责比较内容、生成备份、覆盖写入和 `[SKIP] Unchanged` 分支。
- `Append-FileWithBackup`：为追加模式保留备份，并在旧内容和新内容之间补空行。
- `Initialize-ProjectDocuments`：集中定义 9 份项目文档骨架内容。

## 风险热点
- `Read-RepoRoot` 和项目安装分支决定实际落盘位置，是最容易把文件写错目录的区域。
- `Write-FileWithBackup` / `Append-FileWithBackup` 同时承担幂等、备份和写入职责，任何判断错误都会直接影响用户现有文件。
- `$SkillContent`、`$GlobalAgentsContent`、`$ProjectAgentsContent` 与文档 here-string 是仓库规范的真实来源，修改它们等于修改未来所有初始化结果。
