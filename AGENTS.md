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