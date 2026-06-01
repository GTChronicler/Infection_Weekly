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
