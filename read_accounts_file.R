library(tidyverse)
library(janitor)

bosbc_accounts <- read_csv("data/bosbc_accounts.csv")

bosbc_accounts <- bosbc_accounts %>%
  mutate(account = gsub('"Times"', '\\"Times\\"', bosbc_accounts$account)) %>%
  mutate(species = gsub("’", "'", bosbc_accounts$species))

bosbc_accounts <- bosbc_accounts %>%
  mutate(species_code = gsub(" ", "%20", bosbc_accounts$species)) %>%
  mutate(species_url = str_c("https://s3.us-west-1.amazonaws.com/membot.com/BirdViewSBC.html?v=2&species=",
                             species_code,
                             "%20only&photosOnly=0&taxaLevel=&date=&loc=&hotspotsOnly=0&birder=&source=checklists&groupMode=checklists"))


sp_codes <- read_csv("data/Clements_eBird_FINAL_2024_10Sep2024.xlsx - eBird v2024.csv")

sp_codes <- sp_codes %>%
  clean_names() %>%
  select(species_code, primary_com_name) %>%
  rename(ebird_sp_code = species_code)

bosbc_accounts <- bosbc_accounts %>%
  left_join(sp_codes, by = c("species" = "primary_com_name"))

bosbc_accounts <- bosbc_accounts %>%
  mutate(ebird_url = str_c("https://ebird.org/species/",
  ebird_sp_code,
  "/US-CA-083"))

bosbc_accounts <- bosbc_accounts %>%
  mutate(cbc_url = str_c("https://linusblomqvist.shinyapps.io/cbc_shiny/?species=",
                         species_code))

bosbc_accounts <- bosbc_accounts %>%
  mutate(bbs_url = str_c("https://linusblomqvist.shinyapps.io/sb_bbs/?species=",
                         species_code))
