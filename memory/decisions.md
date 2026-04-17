# Decisions

- 仓库采用 `harness-session` 作为所有非 trivial 会话的强制工作流。原因是脚本既会改全局目录，也会改项目目录，必须要求先读指令、先计划、先验证。影响范围覆盖全局 `AGENTS.md`、项目 `AGENTS.md` 和文档写回流程。
- 所有文件输出统一使用 UTF-8 无 BOM，并在覆盖或追加前保留 `.bak.<timestamp>` 备份。原因是安装器主要操作文本规范文件，编码一致性和可回滚性比写入速度更重要。影响范围覆盖 `SKILL.md`、两个 `AGENTS.md` 和全部项目文档。
- 项目文档结构固定为 `MISSION.md`、`plans/active/current.md`、`docs/*`、`reports/run_log.md`、`memory/*`。原因是脚本已经把这些路径作为初始化标准，后续会话也依赖这组文件承载目标、约束、运行记录和长期记忆。
