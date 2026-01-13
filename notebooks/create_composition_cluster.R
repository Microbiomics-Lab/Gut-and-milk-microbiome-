create_composition_plot = function(
    group_name, 
    cluster_data, 
    otu_data, 
    sample_data, 
    tax_data, 
    color_palette,
    tax_level = "Genus",
    top_n = 20
) {

  current_clusters = cluster_data %>% filter(group == group_name)
  condition_ids = current_clusters %>% pull(sample_id)
  
  OTU_plot = otu_data[, colnames(otu_data) %in% condition_ids, drop = FALSE]
  OTU_plot_phyloseq = otu_table(as.matrix(OTU_plot), taxa_are_rows = TRUE)

  samples_df = data.frame(sample_data)
  samples_plot_df = samples_df %>%
    filter(sam_ %in% condition_ids) %>%
    left_join(current_clusters, by = c("sam_" = "sample_id"))
  rownames(samples_plot_df) = samples_plot_df$sam_
  samples_plot_phyloseq = sample_data(samples_plot_df)
  
  physeq_obj = phyloseq(OTU_plot_phyloseq, samples_plot_phyloseq, tax_data)

  percentages_glom = tax_glom(physeq_obj, taxrank = tax_level)
  percentages_df = psmelt(percentages_glom)
  
  taxa_means = percentages_df %>%
    group_by(.data[[tax_level]]) %>%
    summarise(mean_abundance = mean(Abundance)) %>%
    arrange(desc(mean_abundance))
    
  top_taxa_names = taxa_means %>%
    top_n(top_n, wt = mean_abundance) %>%
    pull(.data[[tax_level]])
    
  plot_df = percentages_df %>%
    mutate(
      Taxon_Display = ifelse(.data[[tax_level]] %in% top_taxa_names, as.character(.data[[tax_level]]), "Other")
    )
    
  plot_df$Taxon_Display = factor(plot_df$Taxon_Display, levels = c(top_taxa_names, "Other"))
  
  relative_plot = ggplot(data = plot_df, aes(x = as.factor(cluster), y = Abundance, fill = Taxon_Display)) +
    geom_bar(stat = "identity", position = "fill") +
    scale_y_continuous(labels = percent_format()) +
    scale_fill_manual(values = color_palette) +
    labs(
      title = paste("Top", top_n, tax_level, "en", group_name),
      x = "Clúster Asignado",
      y = "Abundancia Relativa (%)",
      fill = tax_level 
    ) +
    theme_minimal()

  summary_table = plot_df %>%
        group_by(cluster, Taxon_Display) %>%
    summarise(
      Total_Abundance_Taxon_Cluster = sum(Abundance, na.rm = TRUE), 
      .groups = 'drop'
    ) %>%
    
    group_by(cluster) %>%
    
    mutate(
      Proportion = Total_Abundance_Taxon_Cluster / sum(Total_Abundance_Taxon_Cluster, na.rm = TRUE) * 100
    ) %>%
    
    ungroup() %>%
    select(cluster, Taxon_Display, Proportion) %>%
    
    pivot_wider(
      names_from = Taxon_Display,
      values_from = Proportion,
      values_fill = 0 
    ) %>%
    t()
  
  colnames(summary_table) = summary_table[1, ]
  summary_table = summary_table[2:nrow(summary_table), ]
  summary_table = data.frame(summary_table)
  
  print("Resume about the average abundance in each cluster:")

  return(list(plot = relative_plot, table = round(summary_table, 4)))
}

# Example:

create_composition_plot(
  group_name = "Milk_I",
  cluster_data = all_clusters_df,
  otu_data = otu_mat,
  sample_data = samples,
  tax_data = TAX,
  tax_level = "Genus",
  top_n = 20,               
  color_palette = coloursg
)