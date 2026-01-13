# Getting the values of Maaslin

Maaslin2::Maaslin2(
  input_data = maas_heces,
  input_metadata = metadata_df_filtrada,
  output = "results_maaslin_stool",
  fixed_effects = c("b_type"),
  reference = "b_type,Vaginal",
  min_abundance = 0.0001,
  min_prevalence = 0.1
)

Maaslin2::Maaslin2(
  input_data = maas_heces,
  input_metadata = metadata_df_filtrada,
  output = "results_maaslin_milk",
  fixed_effects = c("b_type"),
  reference = "b_type,Vaginal",
  min_abundance = 0.0001,
  min_prevalence = 0.1
)

results_stool = read.delim(paste0(gen_path, "Code/results_maaslin_stool/all_results.tsv"))
results_milk = read.delim(paste0(gen_path, "Code/results_maaslin_milk/all_results.tsv"))

# Stool

results_sig_h = results_stool %>%
  filter(qval < 0.25) %>%
  mutate(sign = ifelse(coef > 0, "Positive", "Negative")) %>%
  mutate(feature = reorder(feature, coef))

results_sig_h %>% 
  ggplot(mapping = aes(x = coef, y = feature, fill = sign)) +
      geom_col() +
      geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
      scale_fill_manual(values = c("Positivo" = "#66CC9A", "Negativo" = "#9999CB")) +
      labs(
        x = "Maaslin Coefficient (Cesárea vs. Vaginal)",
        y = "Taxón"
      ) +
      theme_bw() +
      theme(legend.position = "none")

# Milk

results_sig_l = results_milk %>%
  filter(qval < 0.25) %>%
  mutate(sign = ifelse(coef > 0, "Positive", "Negative")) %>%
  mutate(feature = reorder(feature, coef))

results_sig_l %>% 
  ggplot(mapping = aes(x = coef, y = feature, fill = sign)) +
      geom_col() +
      geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
      scale_fill_manual(values = c("Positive" = "#66CC9A", "Negative" = "#9999CB")) +
      labs(
        x = "Maaslin Coefficient (Cesárea vs. Vaginal)",
        y = "Taxón"
      ) +
      theme_bw() +
      theme(legend.position = "none")