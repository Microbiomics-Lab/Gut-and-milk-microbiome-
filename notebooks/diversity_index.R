# This graph is for Diversity - Index

diversity_indices = estimate_richness(HMS_rarefied, measures = c("Observed", "Shannon", "Simpson"))

diversity_indices$type_of_sample = ifelse(
  startsWith(rownames(diversity_indices), "MH"),
  "Stool", "Milk")

diversity_indices = diversity_indices %>% 
  mutate(time_of_sample = case_when(
    endsWith(rownames(diversity_indices), ".I") ~ "T1",
    endsWith(rownames(diversity_indices),  ".II") ~ "T2",
    endsWith(rownames(diversity_indices), ".III") ~ "T3",
  )
)

small_constant = 1e-9

diversity_indices = diversity_indices %>%
  mutate(
    Simpson_adjusted = case_when(
      Simpson == 0 ~ Simpson + small_constant,
      Simpson == 1 ~ Simpson - small_constant,
      TRUE ~ Simpson
    ),
    logit_Simpson = log(Simpson_adjusted / (1 - Simpson_adjusted))
  )

# (A) Simpson en Heces (Stool)

p1_s = diversity_indices %>%
  filter(type_of_sample == "Stool") %>%
  ggplot(aes(x = time_of_sample, y = logit_Simpson)) +
  geom_boxplot() + 
  labs(
    y = "logit(SDI)",
    x = "Time Point",
    title = "Infante Stool"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(1, 4))

# (B) Simpson en Leche Materna (Breast Milk)

p2_m = diversity_indices %>%
  filter(type_of_sample == "Milk") %>% # Solo cambiamos el filtro
  ggplot(aes(x = time_of_sample, y = logit_Simpson)) +
  geom_boxplot() +
  labs(
    y = "logit(SDI)",
    x = "Time Point",
    title = "Breast Milk"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(1, 4))

# (C) Shannon en Heces (Stool)

p3_s = diversity_indices %>%
  filter(type_of_sample == "Stool") %>%
  ggplot(aes(x = time_of_sample, y = Shannon)) +
  geom_boxplot() +
  labs(
    y = "ShDI",
    x = "Time Point",
    title = "Infante Stool"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(0, 5))

# (D) Shannon and Milk

p4_m = diversity_indices %>%
  filter(type_of_sample == "Milk") %>%
  ggplot(aes(x = time_of_sample, y = Shannon)) +
  geom_boxplot() +
  labs(
    y = "ShDI",
    x = "Time Point",
    title = "Breast Milk"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(0, 5))

# (E) Observed and Stool

p5_s = diversity_indices %>%
  filter(type_of_sample == "Stool") %>%
  ggplot(aes(x = time_of_sample, y = Observed)) +
  geom_boxplot() +
  labs(
    y = "Observed",
    x = "Time Point",
    title = "Infante Stool"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(10, 100))

# (F) Observed Milk

p6_m = diversity_indices %>%
  filter(type_of_sample == "Milk") %>%
  ggplot(aes(x = time_of_sample, y = Observed)) +
  geom_boxplot() +
  labs(
    y = "Observed",
    x = "Time Point",
    title = "Breast Milk"
  ) + 
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )  +
  coord_cartesian(ylim = c(10, 100))
