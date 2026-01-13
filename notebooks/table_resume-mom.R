# Table resumen for mom

maternal_labels = list(
  ab_gest ~ "Gestation Antibiotics",
  ab_birth ~ "Birth Antibiotics",
  imc_mom ~ "Maternal BMI (end of pregnancy)",
  imc_categoria ~ "Maternal BMI Category"
)

maternal_vars = sapply(maternal_labels, function(x) as.character(x[[2]]))

df_filtrado_mater = df %>% 
  group_by(p_code) %>%
  filter(n_distinct(samp_n) >= 2) %>% 
  select(maternal_vars, p_code, samp_n) %>% 
  summarise(
    imc_mom = round(mean(imc_mom, na.rm = TRUE), 4),
    ab_gest = names(sort(table(ab_gest), decreasing = TRUE))[1],
    ab_birth = names(sort(table(ab_birth), decreasing = TRUE))[1],
    imc_categoria = names(sort(table(imc_categoria), decreasing = TRUE))[1]
  ) %>%
  ungroup()

  table_mom = df_filtrado_mater %>%
  select(all_of(maternal_vars)) %>%
  tbl_summary(
    label = maternal_labels,
    statistic = list(
      all_categorical() ~ "{n} ({p}%)",
      all_continuous() ~ "{mean} [{min} – {max}]" 
    ),
    digits = all_continuous() ~ 2
  ) %>%
  bold_labels() 