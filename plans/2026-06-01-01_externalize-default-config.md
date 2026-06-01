# 2026-06-01-01 Move DEFAULT Parameters to Plain Text Config

## Summary
把 `scripts/main_v0_2.R` 中 `DEFAULT` 区域的日期和疾病列表移到一个纯文本配置文件中，方便同事修改；同时从本次开始保存正式计划到 `plans/` 目录，并用 `YYYY-MM-DD-NN` 编号把 plan、changelog、commit 对应起来。

## Key Changes
- 新增计划档案：
  - `plans/2026-06-01-01_externalize-default-config.md`
  - 文件内容保存本计划，标题使用 `2026-06-01-01` 编号。
- 新增 `config/report_config.txt`，使用 UTF-8 BOM 纯文本：
  ```text
  [settings]
  date_Mon=20260518

  [overview_diseases]
  新型冠状病毒感染
  流行性感冒
  其他感染性腹泻病
  手足口病
  痢疾
  猩红热
  猴痘

  [focus_diseases]
  新型冠状病毒感染
  流行性感冒
  其他感染性腹泻病
  手足口病
  ```
- 在脚本中新增轻量配置读取逻辑：
  - 读取 `[settings]`、`[overview_diseases]`、`[focus_diseases]`
  - 忽略空行和以 `#` 开头的注释行
  - 将 `date_Mon`、`intst_1`、`intst_2` 从配置文件赋值
- 移除 `DEFAULT` 区域三组硬编码值，改为从配置读取。
- 更新双语 changelog，新增编号条目：
  - `2026-06-01-01 Move DEFAULT Parameters to Plain Text Config / 外置 DEFAULT 参数到纯文本配置`
- 保留当前未提交的 B 表附加行分离逻辑，不回退已有改动。
- 后续提交使用 commit message：
  - `2026-06-01-01 Externalize default config`

## Output Equivalence Test
- 改动前先生成基准输出并保存到临时目录。
- 改动后重新运行：
  ```powershell
  Rscript scripts\main_v0_2.R
  ```
- 比对标准采用“内容一致”：
  - `table_beta.csv`：文本内容完全一致
  - `output_beta.docx`：提取 `word/document.xml` 中正文内容后比对一致
- 不要求 `.docx` 二进制哈希完全一致，因为 Word 文件可能包含生成元数据或压缩差异。
- 确认 `input_database/` 和 `outputs/` 中实际数据/结果仍被 `.gitignore` 忽略。

## Assumptions
- 从本次开始保存正式计划，不补录历史计划。
- 从本次开始用 `YYYY-MM-DD-NN` 编号对应 plan、changelog 和 commit。
- 同事使用记事本、VS Code、Positron 等纯文本编辑器修改 `report_config.txt`，不建议用 Excel 编辑。
- 这次只外置当前 `DEFAULT` 区域参数，不外置输入路径、输出路径、健康提示固定文本或其他业务规则。
- `date_Mon` 继续使用 `YYYYMMDD` 格式，例如 `20260518`。
