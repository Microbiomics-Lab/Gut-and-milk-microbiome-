# Table resumen for child

infant_labels = list(
  b_type ~ "Birth Type",
  ab_baby ~ "Infant Antibiotics",
  bm_excl ~ "Exclusive Breastfeeding",
  animal_cont ~ "Animal Contact",
  daycare ~ "Daycare Attendance",
  gest_week ~ "Gestational Week",
  colic ~ "Colic",
  b_bh ~ "Birth Height (cm)",
  g_index ~ "Growth Index"
)

infant_vars = sapply(infant_labels, function(x) as.character(x[[2]]))

df_infant_resumen = df %>%
  select(infant_vars, p_code, samp_n) %>%
  group_by(p_code) %>%
  filter(n_distinct(samp_n) >= 2) %>% # Se debe de tener solo 2 o 3 muestreos
  summarise(
    across(
      all_of(cont_vars), 
      ~ round(mean(.x, na.rm = TRUE), 4), 
      .names = "{.col}"
    ),
    across(
      setdiff(infant_vars, cont_vars), 
      ~ names(sort(table(.x), decreasing = TRUE))[1], 
      .names = "{.col}"
    )
  ) %>%
  ungroup()

table_infant = df_infant_resumen %>%
  select(all_of(infant_vars)) %>%
  tbl_summary(
    label = infant_labels,
    type = list(gest_week ~ "continuous"), 
    statistic = list(
      all_categorical() ~ "{n} ({p}%)",
      all_continuous() ~ "{mean} [{min} – {max}]"
    ),
    digits = all_continuous() ~ 2 
  ) %>%
  bold_labels()
