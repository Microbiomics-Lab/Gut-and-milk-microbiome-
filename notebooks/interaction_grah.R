# This code is for the analysis about the interaction between the time and taxon

plot_microbe_abundance = function(microbe_name, data) {
  
  filtered_data = data[data$Microbio == microbe_name, ]
  
  filtered_data %>% 
    ggplot(mapping = aes(x = time, y = Abundancia, group = b_type)) +
    stat_summary(fun= 'mean', geom = 'line', aes(linetype = b_type, color = b_type)) +
    labs(
      fill = 'Tipo de parto',     
      linetype = 'Tipo de parto', 
      color = 'Tipo de parto',    
      x = 'Tiempo',
      y = 'Abundancia Relativa',
      title = microbe_name
    ) +
    stat_summary(
    fun.max = ~quantile(., 0.75),
    fun.min = ~quantile(., 0.25),
    fun =  mean,
    mapping = aes(color = b_type)
    ) +
    theme_minimal() +
    scale_x_continuous(breaks = c(1, 2, 3)) +
    coord_cartesian(ylim = c(0, 0.5))
}

# Example

g2.1 =  plot_microbe_abundance("tax1", data)
g2.2 =  plot_microbe_abundance("tax2", data)