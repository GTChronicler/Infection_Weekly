### ----------------- FOR THE FIRST TIME --------------------------
# install.packages("tidyverse")
# install.packages("readxl")
# install.packages("officer")
# install.packages("writexl")

### ----------------- PACKAGES ---------------------------
library(tidyverse)
library(readxl)
library(officer)
library(flextable)

# ------------------------ DEFAULT -------------------------------
date_Mon <- c("20260518") # 输入此次周报所描述周的周一日期

intst_1 <- list(
  # 输入“疫情概况”章节想要分析的疾病
  "新型冠状病毒感染",
  "流行性感冒",
  "其他感染性腹泻病",
  "手足口病",
  "痢疾",
  "猩红热",
  "猴痘"
)

intst_2 <- list(
  # 输入“重点疫情”章节想要分析的疾病
  "新型冠状病毒感染",
  "流行性感冒",
  "其他感染性腹泻病",
  "手足口病"
)

# ------------------------ FUNCTIONS -----------------------------
RATECALC <- function(l, f) {
  r <- (l - f) / f * 100
  abs <- abs(r)
  sen <- ifelse(
    is.infinite(r),
    sprintf("增加%d例", l - f),
    ifelse(
      is.nan(r),
      sprintf("一致"),
      ifelse(
        r > 0,
        sprintf("上升%0.2f%%", abs),
        ifelse(
          r == 0,
          "一致",
          sprintf("下降%0.2f%%", abs)
        )
      )
    )
  )
  return(sen)
}

DISTCALC <- function(l, f) {
  dist <- l - f
  r <- dist / f * 100
  abs <- abs(dist)
  sen <- ifelse(
    is.infinite(r) | is.nan(r) | r == 0,
    "",
    ifelse(
      dist > 0,
      sprintf("（增加%d例）", abs),
      sprintf("（减少%d例）", abs)
    )
  )
  return(sen)
}

OVERVIEWTIER <- function(df) {
  tier <- df[["tier"]][[1]]
  count_l <- df %>% pull(本期发病数) %>% sum()
  class <- (df %>% pull(本期发病数) != 0) %>% sum()
  count_f <- df %>% pull(上期发病数) %>% sum()
  r <- RATECALC(count_l, count_f)

  if (count_l == 0) {
    sen <- sprintf(
      "%s传染病无病例报告。",
      tier
    )
  } else {
    sen <- sprintf(
      "%s传染病报告%d种%d例，发病数较上周（%d例）%s；",
      tier,
      class,
      count_l,
      count_f,
      r
    )
  }

  t <- tibble(tier, count_l, sen)

  return(t)
}

RATEDISEASES <- function(v, df) {
  df <- df %>% filter(diseases == v)
  count_l <- df[["本期发病数"]][[1]]
  count_f <- df[["上期发病数"]][[1]]
  r <- RATECALC(count_l, count_f)
  dist <- DISTCALC(count_l, count_f)
  tier <- df[["tier"]][[1]]

  sen_1 <- sprintf("%s较上周%s%s", v, r, dist)
  sen_2 <- sprintf(
    "本周报告%d例，较上周（%d例）%s%s，较去年同期（%d例）%s%s，",
    count_l,
    count_f,
    r,
    dist,
    df[["去年同期发病数"]][[1]],
    RATECALC(count_l, df[["去年同期发病数"]][[1]]),
    DISTCALC(count_l, df[["去年同期发病数"]][[1]])
  )
  sen_3 <- sprintf(
    "本年度累计报告%d例，较去年同期（%d例）%s%s。",
    df[["本年至本期累计发病数"]][[1]],
    df[["去年至本期累计发病数"]][[1]],
    RATECALC(
      df[["本年至本期累计发病数"]][[1]],
      df[["去年至本期累计发病数"]][[1]]
    ),
    DISTCALC(
      df[["本年至本期累计发病数"]][[1]],
      df[["去年至本期累计发病数"]][[1]]
    )
  )

  t <- tibble(
    tier,
    sen_1,
    sen_2,
    sen_3
  )

  return(t)
}

MERGETIER <- function(t, df_1, df_2) {
  df_1 <- df_1 %>% filter(tier == t)
  df_2 <- df_2 %>% filter(tier == t)
  if (df_1[["count_l"]][[1]] == 0) {
    sen <- df_1[["sen"]][[1]]
  } else {
    sen <- sprintf(
      "%s其中%s。",
      df_1[["sen"]][[1]],
      paste0(df_2[["sen_1"]], collapse = "，")
    )
  }

  return(sen)
}

AGECALC <- function(v, df) {
  n_all <- df %>% pull(n) %>% sum()
  if (v == "5岁及以下") {
    df <- df %>% filter(age >= 0 & age <= 5)
  } else if (v == "6-19岁") {
    df <- df %>% filter(age >= 6 & age <= 19)
  } else if (v == "20-59岁") {
    df <- df %>% filter(age >= 20 & age <= 59)
  } else {
    df <- df %>% filter(age >= 60)
  }
  n_d <- df %>% pull(n) %>% sum()
  if (n_d != 0) {
    sen <- sprintf(
      "%s报告%d例（占%.2f%%）",
      v,
      n_d,
      n_d / n_all * 100
    )
  } else {
    sen <- sprintf(
      "%s报告%d例",
      v,
      n_d
    )
  }
  return(sen)
}

DISEASES <- function(v, df_1, df_2) {
  df_2 <- df_2 %>% filter(diseases == v)
  tier <- df_2[["tier"]][[1]]
  d <- df_2[["疾病病种"]][[1]]
  df_1 <- df_1 %>% select(contains(c("疾病病种", d))) %>% `[`(c(1, 4))
  colnames(df_1) <- c("age", "n")
  df_1 <- df_1 %>%
    slice(-(1:3)) %>%
    mutate(
      age = str_replace_all(age, "-", "") %>%
        str_replace_all("及以上", "") %>%
        str_replace_all("不详", "-1") %>%
        as.numeric(),
      n = str_replace_all(n, "-", "0") %>% as.numeric()
    )
  n <- df_1 %>% pull(n) %>% sum()

  sen_age <- list("5岁及以下", "6-19岁", "20-59岁", "60岁及以上") %>%
    map_chr(AGECALC, df_1) %>%
    paste0(collapse = "，")
  df_sens <- RATEDISEASES(v, df_2)

  sen_1 <- sprintf("%s周病例数趋势见图", df_sens[["sen_2"]][[1]])
  sen_2 <- sprintf("本周报告病例中，%s。", sen_age)
  sen_3 <- df_sens[["sen_3"]][[1]]

  t <- tibble(v, tier, n, sen_1, sen_2, sen_3)

  return(t)
}

# ------------------------ INPUT ---------------------------------
df_age <- read_excel("input_database/A.xlsx", skip = 1) %>% as_tibble()
df_raw <- read_excel("input_database/B.xlsx", skip = 1) %>% as_tibble()
df_dict <- read.csv(
  "config/dictionary.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "GBK"
)

# ------------------------ RESHAPE -------------------------------
date_Mon <- date_Mon %>% ymd()
date_Sun <- date_Mon + 6
week <- date_Mon %>% isoweek()
year <- date_Mon %>% year()

df_all <- df_raw %>%
  mutate(
    疾病病种 = str_remove_all(疾病病种, " ")
  ) %>%
  left_join(df_dict) %>%
  filter(tier %in% c("甲类", "乙类", "丙类"))

# ------------------------ PART I --------------------------------
count_all <- df_all %>% pull(本期发病数) %>% sum()
class_all <- (df_all %>% pull(本期发病数) != 0) %>% sum()
df_all <- df_all %>%
  mutate(
    rate = 本期发病数 / count_all
  )

death_all <- df_all %>%
  filter(本期死亡数 != 0) %>%
  select(diseases, 本期死亡数) %>%
  arrange(-本期死亡数) %>%
  mutate(
    sen = sprintf("%s%d例", diseases, 本期死亡数)
  )
count_death <- death_all %>% pull(本期死亡数) %>% sum()

count_fifth <- df_all %>%
  arrange(-本期发病数) %>%
  filter(本期发病数 >= 本期发病数[5]) %>%
  select(diseases, 本期发病数, rate) %>%
  mutate(
    sen = sprintf("%s（%d例）", diseases, 本期发病数)
  )
rate_fifth <- count_fifth %>% pull(rate) %>% sum() %>% `*`(100)

p1_1 <- sprintf(
  "%d年第%d周全市共报告法定传染病%d种%d例，死亡%d例%s，详见附表。报告病例数居前%d位的病种依次为：%s，共占法定传染病报告发病数的%.2f%%。与上周（%d例）相比传染病报告发病数%s。",
  year,
  week,
  class_all,
  count_all,
  count_death,
  ifelse(
    nrow(death_all) == 0,
    "",
    death_all %>%
      pull(sen) %>%
      paste0(collapse = "，") %>%
      paste0("（", ., "）", collapse = "")
  ),
  nrow(count_fifth),
  count_fifth %>% pull(sen) %>% paste0(collapse = "、"),
  rate_fifth,
  df_raw[[3]][[1]],
  RATECALC(df_raw[[2]][[1]], df_raw[[3]][[1]])
)

sens_tier <- df_all %>%
  group_by(tier) %>%
  group_split() %>%
  map_df(OVERVIEWTIER)

sens_1 <- intst_1 %>% map_df(RATEDISEASES, df_all)

p1_2 <- list("甲类", "乙类", "丙类") %>%
  map_chr(MERGETIER, sens_tier, sens_1) %>%
  paste0(collapse = "")

# ------------------------ PART II -------------------------------
colnames(df_age) <- colnames(df_age) %>% str_remove_all(" ")
df_age <- df_age %>%
  select(-contains(df_dict %>% filter(tier == "N") %>% pull(疾病病种)))

dict_num <- tibble(
  order = 1:10,
  label = c(
    "（一）",
    "（二）",
    "（三）",
    "（四）",
    "（五）",
    "（六）",
    "（七）",
    "（八）",
    "（九）",
    "（十）"
  )
)

sens_2 <- intst_2 %>%
  map_df(DISEASES, df_age, df_all) %>%
  mutate(
    tier = factor(tier, levels = c("甲类", "乙类", "丙类"))
  ) %>%
  arrange(tier, -n) %>%
  mutate(
    order = row_number()
  ) %>%
  left_join(dict_num) %>%
  mutate(
    title = paste0(label, v),
    sen = sprintf("%s%d。%s%s", sen_1, order, sen_2, sen_3)
  ) %>%
  select(title, sen)

# ------------------------ PART III ------------------------------
r <- (df_raw[[2]][[1]] - df_raw[[3]][[1]]) / df_raw[[3]][[1]] * 100
if (r >= 10) {
  sens_3 <- "明显上升"
} else if (r >= 5) {
  sens_3 <- "略有上升"
} else if (r > -5) {
  sens_3 <- "基本持平"
} else if (r >= -10) {
  sens_3 <- "略有下降"
} else {
  sens_3 <- "明显下降"
}

rt <- df_all %>%
  filter(type == "呼吸道传染病") %>%
  summarise(sum(本期发病数), sum(rate) * 100)

dt <- df_all %>%
  filter(type == "肠道传染病") %>%
  summarise(sum(本期发病数), sum(rate) * 100)

p3_1 <- sprintf(
  "本周我市法定传染病报告发病数较上周%s（%.2f），其中呼吸道传染病（新型冠状病毒感染、流行性感冒、肺结核、百日咳、猩红热等）报告%d例（占%.0f%%），肠道传染病（痢疾、手足口病、其他感染性腹泻病等）报告%d例（占%.0f%%）。",
  sens_3,
  r,
  rt[[1]],
  rt[[2]],
  dt[[1]],
  dt[[2]]
)

# ------------------------ TABLE ---------------------------------
table <- df_all %>%
  filter(本期发病数 != 0) %>%
  arrange(-本期发病数) %>%
  select(diseases, 本期发病数, 本期死亡数)

colnames(table) <- c("病名", "发病数", "死亡数")

table <- table %>%
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE))) %>%
  mutate(病名 = "甲乙丙类总计") %>%
  select(病名, 发病数, 死亡数) %>%
  bind_rows(table)

# ------------------------ FORMAT --------------------------------
output <- read_docx() %>%
  body_add_fpar(
    fpar(
      "一、疫情概况"
    )
  ) %>%
  body_add_fpar(
    fpar(
      p1_1
    )
  ) %>%
  body_add_fpar(
    fpar(
      p1_2
    )
  ) %>%
  body_add_fpar(
    fpar(
      "\n"
    )
  ) %>%
  body_add_fpar(
    fpar(
      "二、重点疫情"
    )
  )

for (i in 1:nrow(sens_2)) {
  output <- output %>%
    body_add_fpar(
      fpar(
        sens_2[i, ][[1]]
      )
    ) %>%
    body_add_fpar(
      fpar(
        sens_2[i, ][[2]]
      )
    )
}

output <- output %>%
  body_add_fpar(
    fpar(
      "\n"
    )
  ) %>%
  body_add_fpar(
    fpar(
      "三、重点疫情健康提示"
    )
  ) %>%
  body_add_fpar(
    fpar(
      p3_1
    )
  )

# ------------------------ OUTPUT --------------------------------
output %>% print("outputs/output_beta.docx")
write.csv(table, "outputs/table_beta.csv", row.names = FALSE, fileEncoding = "GBK")
