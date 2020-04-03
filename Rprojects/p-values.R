# =======================================
# =   Interpretación de los p-valores   =
# =           Daniel Jiménez            =
# =     Principal Data Scientist        = 
# =             Chiper SAS              =
# =             2020-04-03              =
# =======================================


## libraries ---------------------------
library(tidyverse);
library(lubridate);
theme_set(theme_classic())


## Cuándo usar un histograma de los p-valores ?----------------
## Cuando tiene cientos de datos y tiene que realizar 
## y se tiene que hacer un análisis de correlaciones de múltiples pruebas de hipótesis 
## y con este gráfico podra ver como se comportan todas las prueba de hipótesis
## y hacer diagnostico de los potenciales problemas   



seattle_pets <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-03-26/seattle_pets.csv") %>%
  mutate(license_issue_date = mdy(license_issue_date)) %>%
  rename(animal_name = animals_name)


Cat <- seattle_pets %>%
  filter(species == "Cat")%>%
  filter(!is.na(animal_name))


name_counts <- Cat %>%
  group_by(animal_name) %>%
  summarize(name_total = n()) %>%
  filter(name_total >= 100)

breed_counts <- Cat %>%
  group_by(primary_breed) %>%
  summarize(breed_total = n()) %>%
  filter(breed_total >= 200)

total_Cat <- nrow(Cat)


name_breed_counts <- Cat %>%
  count(primary_breed, animal_name) %>%
  complete(primary_breed, animal_name, fill = list(n = 0)) %>%
  inner_join(name_counts, by = "animal_name") %>%
  inner_join(breed_counts, by = "primary_breed")



hypergeom_test <- name_breed_counts %>%
  mutate(percent_of_breed = n / breed_total,
         percent_overall = name_total / total_Cat) %>%
  mutate(overrepresented_ratio = percent_of_breed / percent_overall) %>%
  arrange(desc(overrepresented_ratio)) %>%
  mutate(hypergeom_p_value = 1 - phyper(n, name_total, total_Cat - name_total, breed_total),
         holm_p_value = p.adjust(hypergeom_p_value),
         fdr = p.adjust(hypergeom_p_value, method = "fdr"))




ggplot(hypergeom_test, aes(hypergeom_p_value)) +
  geom_histogram(binwidth = .1) +
  labs(x = "One-sided hypergeometric p-values for overrepresented name")

## Parece ser uniforme, todas las hipótesis son nulas 
## No se puede aceptar todos los valores p menores a .5

