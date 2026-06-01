# 2026-06-02-01 Rename Main Script to Version 1.0

## Summary
将主脚本从临时开发名称 `main_v0_2.R` 重命名为正式版本名称 `infection_weekly_report_v1_0.R`，使文件名更清楚地表达项目用途和版本号。

## Key Changes
- 重命名脚本：
  - `scripts/main_v0_2.R` -> `scripts/infection_weekly_report_v1_0.R`
- 不修改脚本内部运行逻辑。
- 更新双语 changelog，记录本次正式命名。

## Validation
- 运行：
  ```powershell
  Rscript scripts\infection_weekly_report_v1_0.R
  ```
- 确认脚本可从项目根目录正常执行。
- 确认本地输入数据库和输出结果仍被 `.gitignore` 忽略。

## Assumptions
- `infection_weekly_report_v1_0.R` 作为当前 1.0 版主入口脚本名称。
- 历史 plan 和 changelog 中引用旧文件名的内容保留为历史记录，不回改。
