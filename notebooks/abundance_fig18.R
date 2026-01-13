# Analizing the abundance with (log10(Abundance) + min(val))

# Stool

datos_en_largo %>% 
  filter(type == "Stool") %>% 
  ggplot(mapping = aes(x = Microbio, y = (log10(Abundancia) + 4.5), fill = b_type)) +
    geom_boxplot() +
    labs(
      x = "Taxón",
      y = "Abundancia Relativa (Log10)",
      fill = "Tipo de Nacimiento"
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Milk

datos_en_largo %>% 
  filter(type == "Milk") %>% 
  ggplot(mapping = aes(x = Microbio, y = (log10(Abundancia) + 4.5), fill = b_type)) +
    geom_boxplot() +
    labs(
      x = "Taxón",
      y = "Abundancia Relativa (Log10)",
      fill = "Tipo de Nacimiento"
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))