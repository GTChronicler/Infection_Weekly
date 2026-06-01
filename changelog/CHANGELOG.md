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

### 2026-06-01-02 Add Other Infectious Diseases to Focus Section / 在重点疫情中新增其他传染病小节
- Added an `其他传染病` subsection at the end of the focus section, listing non-zero rows from `B.xlsx` extra rows by current case count, with each disease sentence in its own paragraph. / 在“重点疫情”末尾新增 `其他传染病` 小节，按本期发病数列出 `B.xlsx` 附加行中本期非 0 的项目，并将每个病种句子单独成段。

## 2026-06-02

### 2026-06-02-01 Rename Main Script to Version 1.0 / 将主脚本重命名为 1.0 版
- Renamed the main script from `scripts/main_v0_2.R` to `scripts/infection_weekly_report_v1_0.R` without changing runtime logic. / 将主脚本从 `scripts/main_v0_2.R` 重命名为 `scripts/infection_weekly_report_v1_0.R`，不修改运行逻辑。

### 2026-06-02-02 Harden Report Config Validation / 加强报告配置校验
- Added strict validation for `date_Mon`, duplicate disease names, disease-data matching, and bilingual UTF-8-related mismatch guidance in `config/report_config.txt`. / 为 `config/report_config.txt` 增加 `date_Mon` 严格日期校验、重复疾病校验、疾病数据匹配校验，以及 UTF-8 编码相关的中英文双语友好提示。

### 2026-06-02-03 Write Project README / 撰写项目 README
- Added a root `README.md` covering project purpose, inputs, configuration, execution, outputs, report contents, common errors, and maintenance conventions; replaced the old A/B file note. / 新增根目录 `README.md`，说明项目用途、输入文件、配置方式、运行命令、输出结果、报告内容、常见错误和维护约定，并替代原来的 A/B 文件说明。

### 2026-06-02-04 Build Standalone Windows GUI EXE / 构建独立 Windows 图形界面 EXE
- Added a Python/Tkinter desktop application and PyInstaller build flow for generating `InfectionWeekly.exe`, using `python-calamine` for Excel compatibility while preserving the existing project folders, configuration file, input/output paths, and report content. / 新增 Python/Tkinter 桌面程序和 PyInstaller 构建流程，用于生成 `InfectionWeekly.exe`，并使用 `python-calamine` 兼容导出的 Excel 文件，同时保持现有项目目录、配置文件、输入输出路径和报告内容不变。

### 2026-06-02-05 Polish Word Fonts and 4K DPI UI / 优化 Word 字体和 4K 界面清晰度
- Set generated Word report text to use SimSun for Chinese and Times New Roman for English in both the R reference script and the standalone EXE path. / 在 R 参考脚本和独立 EXE 生成路径中，将生成的 Word 报告文本设置为中文宋体、英文 Times New Roman。
- Enabled Windows DPI awareness and Tk scaling for the desktop UI to improve clarity on 4K/high-DPI displays. / 为桌面界面启用 Windows DPI 感知和 Tk 缩放，以改善 4K/高 DPI 屏幕下的显示清晰度。
