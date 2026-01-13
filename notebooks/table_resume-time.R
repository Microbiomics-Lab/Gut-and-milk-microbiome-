# This table resume is for three times point

info_labels = list(
  ab_mom ~ "Maternal Antibiotics",
  f_type ~ "Feeding Type",
  pro_bio ~ "Probiotic Consumption"
)

info_vars = sapply(info_labels, function(x) as.character(x[[2]]))

df_filtrado_info = df %>% 
  mutate(
    time_ = case_when(
      samp_n == 1 ~ 'I',
      samp_n == 2 ~ 'II',
      samp_n == 3 ~ 'III'
    )
  ) %>% 
  filter(n_distinct(samp_n) >= 2) %>%
  select(info_vars, p_code, time_)

table_info = df_filtrado_info %>%
  select(all_of(info_vars), time_) %>%
  tbl_summary(
    by = time_,
    label = info_labels,
    statistic = list(
      all_categorical() ~ "{n} ({p}%)"
    )
  ) %>%
  bold_labels() 