# 2026-06-02-02 Harden Report Config Validation

## Summary
加强 `config/report_config.txt` 的读取和校验，让同事改配置时如果写错日期、疾病名、重复疾病或保存成错误编码，脚本能用清楚的错误信息停止，而不是生成 `NA年第NA周`、重复段落或底层报错。保持报告正常输出逻辑不变。

## Key Changes
- `date_Mon` 严格校验为真实的 `YYYYMMDD` 日期。
- `[overview_diseases]` 和 `[focus_diseases]` 出现重复疾病时直接报错。
- 配置疾病名必须能匹配实际分析数据；重点疫情疾病还必须能匹配 A 表年龄数据。
- 配置错误提示使用中英文双语；疾病名无法匹配时，提示检查拼写和 UTF-8 编码。
- 不改变统计计算公式、排序逻辑、输出路径或文本模板。

## Test Plan
- 正常配置：当前默认配置、UTF-8 无 BOM、带注释空行和等号空格的配置均应通过。
- 错误配置：非法日期、不存在疾病、重复疾病、空 section、缺少 `[settings]`、未知 section、GBK/ANSI 保存均应友好失败。
- 成功场景确认 Word/CSV 正常生成，正文无 `NA年第NA周` 和典型乱码，“其他传染病”小节仍正常生成。
- 失败场景确认不会生成新的 Word/CSV。
- 确认输入数据和输出结果仍被 `.gitignore` 忽略。

## Assumptions
- `report_config.txt` 标准编码为 UTF-8，允许 UTF-8 BOM 或 UTF-8 无 BOM。
- 日期格式只接受 8 位数字 `YYYYMMDD`。
- 疾病名重复一律视为配置错误，不自动去重。
