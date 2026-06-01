# Infection Weekly

传染病周报自动生成项目。脚本会读取本地输入数据库 `A.xlsx` 和 `B.xlsx`，结合配置文件和疾病字典，生成 Word 周报和 CSV 附表。

本仓库只保存脚本、配置模板、字典和维护记录；真实输入数据和生成结果默认保留在本地，不提交到 GitHub。

## 项目结构

```text
config/           用户可调整配置和疾病字典
input_database/   本地输入数据，放置 A.xlsx 和 B.xlsx，不提交
outputs/          本地生成结果，不提交
scripts/          R 主脚本
plans/            已实施计划档案
changelog/        双语修改日志
```

主脚本：

```powershell
Rscript scripts\infection_weekly_report_v1_0.R
```

也可以使用根目录下生成的桌面程序：

```text
InfectionWeekly.exe
```

## 输入文件

请将以下两个 Excel 文件放入 `input_database/`，文件名需要保持不变：

```text
input_database/A.xlsx
input_database/B.xlsx
```

`A.xlsx` 是分年龄统计表。脚本读取 `Report` 工作表，跳过第 1 行，用于“二、重点疫情”中各重点疾病的年龄分布描述。配置在 `[focus_diseases]` 中的疾病，需要能在 `A.xlsx` 中找到对应年龄数据列。

`B.xlsx` 是疫情分析统计表。脚本读取 `Report` 工作表，跳过第 1 行，用于计算疫情概况、重点疫情趋势、累计发病、死亡数和附表。脚本会把 `B.xlsx` 第一列中 `其他传染病` 这一行及其后所有行从主分析数据中分离出来，并在“二、重点疫情”末尾生成“其他传染病”小节。

`B.xlsx` 至少需要包含这些字段：

```text
疾病病种
本期发病数
上期发病数
去年同期发病数
本年至本期累计发病数
去年至本期累计发病数
本期死亡数
```

## 配置文件

主要修改 `config/report_config.txt`。请使用记事本、VS Code、Positron 等纯文本编辑器保存为 UTF-8，不建议用 Excel 打开或保存。

```text
[settings]
date_Mon=20260518

[overview_diseases]
新型冠状病毒感染
流行性感冒

[focus_diseases]
新型冠状病毒感染
流行性感冒
```

`date_Mon` 填写本次周报所描述周的周一日期，只接受真实的 `YYYYMMDD` 日期，例如 `20260518`。

`[overview_diseases]` 控制“一、疫情概况”中按甲乙丙类概述时点名比较的疾病。疾病名需要与 `config/dictionary.csv` 的 `diseases` 列一致，并且需要能在 `B.xlsx` 主分析数据中匹配。

`[focus_diseases]` 控制“二、重点疫情”中展开分析的疾病。疾病名需要能在 `B.xlsx` 主分析数据中匹配，也需要能在 `A.xlsx` 分年龄数据中匹配。

同一个 section 内不要重复填写疾病名。脚本会提前检查日期、重复疾病、疾病名匹配和常见编码问题；如果配置有误，会用中英文双语错误信息停止。

`config/dictionary.csv` 是疾病字典，用于把原始疾病名称映射到报告使用名称、甲乙丙类和传播类型。日常生成周报通常只需要改 `report_config.txt`，不要随意改字典。

## 运行方法

首次运行前请确认已经安装 R 和所需包：

```r
install.packages(c("tidyverse", "readxl", "officer", "flextable"))
```

从项目根目录运行：

```powershell
Rscript scripts\infection_weekly_report_v1_0.R
```

如果使用桌面程序，双击根目录下的 `InfectionWeekly.exe`。程序打开后会自动读取当前 `config/report_config.txt`，在界面中显示当前日期和疾病选择；也可以在界面中选择新的 A/B 文件、保存配置并生成报告。

生成结果：

```text
outputs/output_beta.docx
outputs/table_beta.csv
```

`output_beta.docx` 是 Word 周报正文。`table_beta.csv` 是附表，使用 GBK 编码，方便直接用中文 Windows 环境下的 Excel 打开。

## 报告内容

脚本当前生成三部分正文和一个附表：

```text
一、疫情概况
二、重点疫情
三、重点疫情健康提示
附表 table_beta.csv
```

“疫情概况”包括总报告数、死亡数、报告病例数居前病种、甲乙丙类概述，以及配置中指定疾病的周变化。

“重点疫情”包括配置中指定疾病的本周发病、与上周和去年同期比较、年龄分布、本年度累计报告，以及自动追加的“其他传染病”小节。

“重点疫情健康提示”根据本周法定传染病报告数较上周变化幅度，生成上升、下降或基本持平描述。

## 常见问题

如果出现 `Missing date_Mon` 或 `date_Mon 格式无效`，请检查 `config/report_config.txt` 中 `[settings]` 是否存在，以及日期是否为真实的 8 位数字日期。

如果出现 `Unknown disease names` 或 `疾病未出现在 B.xlsx/A.xlsx`，请检查疾病名是否与 `dictionary.csv`、`A.xlsx`、`B.xlsx` 中的名称一致。脚本会忽略疾病名称中的空格，但不会自动修正常见错别字。

如果出现编码相关提示，请确认 `report_config.txt` 是 UTF-8 编码。不要用 Excel 保存这个文件。

如果脚本提示找不到 `A.xlsx` 或 `B.xlsx`，请确认两个文件已经放在 `input_database/`，并且文件名完全一致。

## 维护约定

输入数据和输出结果由 `.gitignore` 忽略，不提交到 GitHub。

桌面程序源码放在 `desktop_app/`。构建 EXE：

```powershell
powershell -ExecutionPolicy Bypass -File desktop_app\build_exe.ps1
```

生成的 `InfectionWeekly.exe` 位于根目录，但不提交到 Git。

桌面程序使用 `python-calamine` 读取导出的 Excel 文件，以兼容部分 `openpyxl` 无法完整读取的本地工作簿。

正式改动需要同步维护：

```text
plans/YYYY-MM-DD-NN_*.md
changelog/CHANGELOG.md
```

计划、changelog 和 commit message 使用同一个 `YYYY-MM-DD-NN` 编号，方便以后回查。
