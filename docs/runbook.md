# Runbook

## 常用命令
- 安装到当前仓库：`powershell -ExecutionPolicy Bypass -File .\install-harness.ps1 -RepoRoot .`
- 交互式安装：`powershell -ExecutionPolicy Bypass -File .\install-harness.ps1`
- 语法检查：`powershell -NoProfile -Command "$tokens=$null;$errors=$null;[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path '.\install-harness.ps1'),[ref]$tokens,[ref]$errors) | Out-Null; if ($errors) { $errors | Out-String | Write-Error; exit 1 }"`
- 可选静态检查：`powershell -NoProfile -Command "Invoke-ScriptAnalyzer -Path .\install-harness.ps1"`
- 查看目标文档改动：`git diff -- MISSION.md plans/active/current.md docs reports memory`

## 最小验证清单
- 修改脚本后先执行 PowerShell Parser 语法检查；这是当前仓库最稳定、依赖最少的基础验证。
- 修改模板或文档后检查 `git diff`，确认改动范围只落在目标文件，没有误触发其他目录。
- 若目标是清理模板骨架，再补一次定向文本扫描，确认初始化文案、日期占位行和未展开变量都已被真实项目说明替换。
- 成功判定：Parser 无错误、目标文件内容与本次任务一致，且安装脚本的公共参数和备份逻辑未被意外破坏。

## 常见问题排查
- 现象：脚本启动后只安装了全局文件，没有安装项目 `AGENTS.md` 或文档。
  排查：检查是否在 `-Force` 模式下没有传 `-RepoRoot`；`Read-RepoRoot` 在这种分支会直接返回空字符串。
  解决：显式传入 `-RepoRoot .` 或在非 `-Force` 模式下通过交互选择项目目录。
- 现象：当前仓库的 `AGENTS.md` 出现重复内容。
  排查：确认之前是否在“当前目录 + 已存在 AGENTS.md + 非 Force”分支选择了追加模式。
  解决：从同目录最近的 `.bak.<timestamp>` 备份恢复，再用覆盖模式重写。
- 现象：脚本报错“无法解析 USERPROFILE”。
  排查：确认 PowerShell 会话里存在 `$env:USERPROFILE`。
  解决：在正常用户环境下运行，或先修复宿主环境变量。
- 现象：`Invoke-ScriptAnalyzer` 无法执行。
  排查：仓库本身不内置该模块。
  解决：把 Parser 检查作为最低验证标准；只有本机已安装 `PSScriptAnalyzer` 时再运行静态检查。

## 变更注意事项
- 高风险操作：写入 `$env:USERPROFILE\.codex`、`$env:USERPROFILE\.agents` 和项目根目录已有文件都会影响现有工作流，必须确认目标路径和写入模式。
- 高风险操作：修改 here-string 模板会改变之后所有新初始化出来的文件内容，应先确认这是仓库层面的长期决策。
- 回滚方式：优先使用脚本自动生成的 `.bak.<timestamp>` 备份文件恢复原状；若只改了文档骨架，也可以借助 `git diff` 选定单个文件回退。
