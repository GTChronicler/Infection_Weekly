# 2026-06-02-03 Write Project README

## Summary
撰写根目录 `README.md`，用完整项目说明替代原来的 `docs/AB文件说明.txt`，让同事能从 GitHub 或项目根目录直接理解输入文件、配置方式、运行命令、输出结果和维护约定。

## Key Changes
- 新增 `README.md`，说明项目用途、目录结构、A/B 输入文件、配置文件、运行方法、输出文件、报告内容和常见问题。
- 删除 `docs/AB文件说明.txt`，由根目录 README 承接 A/B 文件说明。
- 更新双语 changelog，记录 README 文档补充。

## Validation
- 确认 README 中的脚本路径、配置路径、输入路径和输出路径与当前项目一致。
- 确认输入数据和输出结果仍被 `.gitignore` 忽略。

## Assumptions
- README 作为项目主要使用者说明，优先放在根目录，方便 GitHub 首页直接展示。
- 旧的 A/B 文件说明内容已被 README 覆盖，不再单独保留。
