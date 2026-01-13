# This code is for the silhouette_plots

silhouette_plots = list()


for (group_name in type_of_cluster_to_graph) {
  
  cat("--- Procesando:", group_name, "---\n")
  
  current_df = cluster_by_time_type[[group_name]]
  
  asv_numeric = current_df %>% 
    select_if(is.numeric)
    
  # If there is not enougt samples
  if (nrow(asv_numeric) < 3) {
    cat("... skiping group: enougt data...\n")
    next
  }

  # Calculating matrix distances
  asv_rel_abund = decostand(asv_numeric, method = "total")
  bray_dist_matrix = vegdist(asv_rel_abund, method = "bray")
  
  silhouette_scores = c()
  for (k in 2:10) {
    if (k >= nrow(asv_numeric)) break # Skip if 'k' is big
    pam_result = pam(bray_dist_matrix, k = k)
    silhouette_scores[k] = pam_result$silinfo$avg.width
  }
  
  n_length = length(silhouette_scores)
  plot_data = data.frame(k = 2:n_length, score = silhouette_scores[2:n_length])
  
  # Saving the new information
  silhouette_plots[[group_name]] = ggplot(plot_data, aes(x = k, y = score)) +
    geom_line() +
    geom_point() +
    labs(
      title = paste("Puntaje de Silueta para", group_name),
      x = "Número de Clústeres (k)",
      y = "Puntaje Promedio de Silueta"
    ) +
    theme_minimal()
}