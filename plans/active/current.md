# Current Plan

## Objective
- 基于 `install-harness.ps1` 与当前仓库目录结构，补全 `MISSION.md`、`plans/active/current.md`、`docs/*`、`reports/run_log.md`、`memory/*`，移除全部初始化模板占位说明。

## Known Facts
- 仓库唯一核心脚本是 `install-harness.ps1`，负责全局 harness skill、全局 `AGENTS.md`、项目 `AGENTS.md` 和文档骨架初始化。
- 脚本使用 `Set-StrictMode -Version Latest` 和 `$ErrorActionPreference = "Stop"`，写文件时通过 `.NET` API 强制使用 UTF-8 无 BOM。
- 已存在文件在覆盖或追加前会生成 `.bak.<timestamp>` 备份；未变化文件会跳过写入。
- 项目文档骨架由 `Initialize-ProjectDocuments` 生成，覆盖 `MISSION.md`、`plans`、`docs`、`reports`、`memory` 目录中的目标文件。
- 当前大部分文档仍是初始化模板；`reports/run_log.md` 已记录一次 `AGENTS.md` 回填动作。

## Unknowns / Blockers
- 未知项：无。
- 阻塞项：无。

## Next Small Step
- 如继续迭代本仓库，优先补一个基于临时目录的安装 smoke check，验证 `-Force`、`-RepoRoot`、备份生成和文档初始化不会回归。

## Validation
- 运行 PowerShell Parser 语法检查，确认 `install-harness.ps1` 仍可被宿主解析。
- 使用 `git diff -- MISSION.md plans/active/current.md docs reports memory` 核对改动范围仅限目标文档。
- 检查目标文档中不再残留初始化文案、未展开的花括号变量或日期占位行。

## Progress Log
- 2026-04-17 16:00: 读取仓库 `AGENTS.md`、`MISSION.md`、`plans/active/current.md`、`docs/constraints.md`、`docs/system_map.md`、`docs/runbook.md` 与 `harness-session` skill，确认本次任务需按 harness 流程执行。
- 2026-04-17 16:07: 通读 `install-harness.ps1`，确认安装目标、交互分支、备份策略、UTF-8 写入方式与文档骨架来源。
- 2026-04-17 16:10: 核对 `reports/run_log.md`、`memory/lessons.md`、`memory/decisions.md` 的现状，确认它们仍为初始化文案。
- 2026-04-17 16:18: 根据脚本事实回填 `MISSION.md`、`plans/active/current.md`、`docs/*`、`reports/run_log.md`、`memory/*`，移除模板占位说明。
- 2026-04-17 16:23: 完成 Parser 检查、`git diff` 核对和模板残留扫描，确认本次改动仅覆盖目标文档且 `install-harness.ps1` 可正常解析。
