# 2026-06-02-04 Build Standalone Windows GUI EXE

## Summary
新增 Win10/Win11 可双击运行的 `InfectionWeekly.exe`。程序使用 Python 重写现有 R 周报生成逻辑，并提供 Tkinter 图形界面，让同事无需安装 R 或 Python 即可导入 A/B 文件、修改配置并生成 Word/CSV 输出。

## Key Changes
- 新增 `desktop_app/`，集中保存桌面程序源码、输出比对工具和 PyInstaller 构建脚本。
- 使用 `python-calamine` 读取 `A.xlsx`、`B.xlsx`，使用 `python-docx` 写入 `outputs/output_beta.docx`，使用 GBK 写入 `outputs/table_beta.csv`。
- UI 启动后默认读取当前 `config/report_config.txt`，显示日期和疾病选择状态。
- UI 支持覆盖导入 `input_database/A.xlsx`、`input_database/B.xlsx`，保存配置，生成报告，并打开 `outputs/`。
- 保留 R 脚本作为参考实现和回归基准。
- 更新 `.gitignore`、README 和双语 changelog。

## Test Plan
- 使用 R 脚本生成基准输出。
- 使用 Python engine 生成候选输出，并比对 CSV 文本和 Word 正文段落一致。
- 构建根目录 `InfectionWeekly.exe`，确认 EXE 可启动且不依赖 Rscript。
- 确认 EXE、输入文件、输出文件和构建临时文件不进入 Git。

## Assumptions
- 采用 Python 重写，不内置 R 运行时。
- 输出等价按 Word 可见正文和 CSV 文本内容一致验收。
- EXE 生成在根目录，但不提交到 Git。
