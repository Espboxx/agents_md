# Docs README

`docs/` 目录保存的是这套 harness 安装器的长期说明文档，目标是把仓库级事实、约束和操作方法固定下来，避免每次会话都重新从脚本推断。

## 建议阅读顺序
1. `MISSION.md`：先了解仓库为什么存在、当前交付范围和成功标准。
2. `AGENTS.md`：确认仓库级工作规则、验证要求和高风险区域。
3. `plans/active/current.md`：查看当前会话正在做什么、已确认事实是什么、下一步是什么。
4. `docs/constraints.md`：理解运行环境、接口边界、兼容性和禁止事项。
5. `docs/system_map.md`：快速定位入口脚本、目录职责、关键流程与风险热点。
6. `docs/runbook.md`：执行常用命令、最小验证和常见排障步骤。

## 文档职责
- `constraints.md`：沉淀由 `install-harness.ps1` 决定的技术边界，例如 PowerShell 运行环境、UTF-8 无 BOM 写入、备份覆盖策略和公共参数约束。
- `system_map.md`：描述 `install-harness.ps1` 如何把全局目录、项目目录和文档骨架串起来，以及 `docs`、`plans`、`reports`、`memory` 这些目录的职责。
- `runbook.md`：记录安装、验证、回滚与排障操作，优先使用仓库里已经存在的命令和最小检查。

## 与 `docs/` 配套的持久化文件
- `plans/active/current.md`：当前任务计划与进度日志，面向单次会话。
- `reports/run_log.md`：已完成工作的时间线记录，保留可追溯证据。
- `memory/lessons.md`：经过验证、值得长期复用的经验。
- `memory/decisions.md`：已经在脚本或仓库结构中落地的关键决策及其原因。
