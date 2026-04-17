# Mission

## 项目目标
- 为 Codex 会话安装并维护一套可复用的 harness 基础设施：全局 `harness-session` skill、全局 `AGENTS.md`、项目级 `AGENTS.md`，以及项目文档骨架。

## 交付范围
- 提供 `install-harness.ps1`，支持交互式或参数化安装到 `$env:USERPROFILE\.codex`、`$env:USERPROFILE\.agents\skills\harness-session` 和指定项目根目录。
- 在项目目录初始化 `MISSION.md`、`plans/active/current.md`、`docs/*`、`reports/run_log.md`、`memory/*` 等文档，并为后续会话提供固定阅读顺序。
- 对已存在文件提供覆盖前备份、追加或覆盖选择、UTF-8 无 BOM 写入与安装结果提示。
- 不包含 Web UI、数据库、网络服务、构建产物或发布流水线。

## 成功标准
- 脚本能根据 `-RepoRoot`、当前目录或手动输入解析目标项目路径，并把目标文件写到预期位置。
- 对已有文件的改写会先生成 `.bak.<timestamp>` 备份；未变化文件会输出 `[SKIP] Unchanged`，避免无意义覆盖。
- 项目级文档骨架、全局 skill 和 `AGENTS.md` 内容与脚本内置模板保持一致，编码为 UTF-8 无 BOM。
- 最直接的仓库级验证是 PowerShell Parser 语法检查通过；运行安装时能看到 `[WRITE]`、`[APPEND]`、`[BACKUP]`、`[SKIP]` 等明确日志。

## 当前阶段
- 当前阶段：维护安装脚本与文档模板，让 harness 能稳定落地到全局环境和任意项目目录。
- 当前优先级：保持安装流程可重复、可回滚、可验证，并把初始化出来的文档从模板状态补全为真实项目说明。
- 当前主要风险：路径解析错误会把文件写到错误目录；覆盖或追加判断错误会污染现有 `AGENTS.md` / `SKILL.md` / 文档；全局目录写入会影响后续所有 Codex 会话。
