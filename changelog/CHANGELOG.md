# Changelog / 修改日志

## 2026-06-01

### Initial open-source project structure / 初始化开源项目结构
- Initialized the Git repository on the `main` branch. / 在 `main` 分支初始化 Git 仓库。
- Organized project files into `config/`, `input_database/`, `outputs/`, `scripts/`, `docs/`, and `changelog/`. / 将项目文件整理到 `config/`、`input_database/`、`outputs/`、`scripts/`、`docs/` 和 `changelog/` 目录。
- Added `.gitignore` rules to keep local input data and generated outputs out of Git. / 添加 `.gitignore` 规则，避免本地输入数据和生成结果进入 Git。
- Added `.gitkeep` placeholders so `input_database/` and `outputs/` remain visible in the repository. / 添加 `.gitkeep` 占位文件，使 `input_database/` 和 `outputs/` 空目录结构能保留在仓库中。

### Update script paths for project directories / 更新脚本路径以适配项目目录
- Updated `scripts/main_v0_2.R` to read inputs from `input_database/` and `config/`. / 更新 `scripts/main_v0_2.R`，从 `input_database/` 和 `config/` 读取输入文件。
- Updated generated report and table outputs to write into `outputs/`. / 更新输出路径，将生成的报告和表格写入 `outputs/`。
- Verified the script runs successfully from the project root with `Rscript scripts/main_v0_2.R`. / 已验证脚本可在项目根目录通过 `Rscript scripts/main_v0_2.R` 成功运行。

### Fix weekly trend percentage display / 修复周趋势百分比显示
- Added the missing percent sign in the health guidance sentence for week-over-week incidence change. / 补充健康提示段落中法定传染病发病数较上周变化值缺失的百分号。

### Separate extra rows from analysis table B / 分离 B 表中的附加行
- Stored `其他传染病` and all following rows from `B.xlsx` in `df_raw_extra`, while keeping the main analysis workflow on the preceding rows. / 将 `B.xlsx` 中 `其他传染病` 及其之后的所有行暂存到 `df_raw_extra`，主分析流程仅使用其之前的行。

### 2026-06-01-01 Move DEFAULT Parameters to Plain Text Config / 外置 DEFAULT 参数到纯文本配置
- Moved the report date and disease list parameters from `scripts/main_v0_2.R` to `config/report_config.txt`. / 将报告日期和疾病列表参数从 `scripts/main_v0_2.R` 外置到 `config/report_config.txt`。
- Started archiving implementation plans in `plans/` with `YYYY-MM-DD-NN` tracking IDs. / 开始在 `plans/` 中保存实施计划，并使用 `YYYY-MM-DD-NN` 编号进行追踪。
