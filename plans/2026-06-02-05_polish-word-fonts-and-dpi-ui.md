# 2026-06-02-05 Polish Word Fonts and 4K DPI UI

## Summary
修复两个体验问题：生成的 Word 文档统一设置中文为宋体、英文为 Times New Roman；同时让 `InfectionWeekly.exe` 在 Win10/Win11 高 DPI/4K 屏幕下不再模糊。功能逻辑、输入输出目录、报告正文内容和 CSV 内容保持不变。

## Key Changes
- Word 字体：
  - 在 Python/EXE 生成路径中，为 `outputs/output_beta.docx` 的正文段落和空行 run 设置字体：`eastAsia = 宋体`，`ascii/hAnsi/cs = Times New Roman`。
  - 在 R 参考脚本中同步设置 `officer::fp_text(font.family = "Times New Roman", eastasia.family = "宋体", hansi.family = "Times New Roman")`，避免 R 生成路径和 EXE 生成路径样式不一致。
  - 不改变段落顺序、正文文本、表格 CSV 或任何统计计算。

- 4K UI 清晰度：
  - 在 Tkinter UI 初始化前启用 Windows DPI awareness，优先使用 per-monitor DPI aware，失败时回退到 system DPI aware。
  - 根据当前 DPI 设置 Tk scaling，并统一默认 UI 字体为适合中文显示的 Windows UI 字体。
  - 保持现有按钮、列表、配置保存、文件覆盖和生成报告流程不变。

- 项目追踪：
  - 新增计划档案 `plans/2026-06-02-05_polish-word-fonts-and-dpi-ui.md`。
  - 更新双语 `changelog/CHANGELOG.md`。
  - 重新构建本地根目录 `InfectionWeekly.exe`，但继续不提交 EXE 文件。

## Test Plan
- 运行 R 脚本和 EXE/Python 生成报告，确认：
  - `outputs/table_beta.csv` 文本内容不变。
  - Word 可见正文段落内容不变。
  - 生成的 `.docx` XML 中包含 `宋体` 和 `Times New Roman` 字体设置。
- 启动 `InfectionWeekly.exe`，确认 UI 能正常打开、读取当前配置、生成报告。
- 做一次 EXE `--generate` 回归测试，确认不调用 R 也能生成同内容 Word/CSV。
- 检查 `git status --ignored`，确认输入文件、输出文件、EXE 和构建产物仍被忽略。

## Assumptions
- “time new roman” 按标准字体名解释为 `Times New Roman`。
- 字体要求适用于 R 参考脚本和 EXE/Python 生成路径。
- 4K 模糊主要由 Windows DPI awareness 缺失导致，本次优先修复 DPI 感知和 Tk 缩放，不重设计 UI 布局。
- 提交信息使用：`2026-06-02-05 Polish Word fonts and DPI UI`。
