
# Libraries

library(readxl)
library(dplyr)
library(leaflet)

# Stations in Anne Fleigs report from 2013

stats_fleig <- c("2.11", "2.13", "2.142", "2.265", "2.268", "2.275", "2.279", "2.280", "2.290", "2.303", "2.323", "2.616",
                 "12.70", "12.171", "12.178", "12.193", "12.197", "12.215", "15.49", "15.53",
                 "16.66", "16.75", "16.122", "16.194", "18.10", "18.11", "19.73", "19.78",
                 "19.79", "19.80", "19.82", "19.96", "19.104", "20.2", "20.11", "22.16", "22.22",
                 "24.8", "24.9", "25.24", "26.20", "26.21", "26.26", "27.15", "35.9", "35.16",
                 "35.13", "38.1", "41.1", "41.8", "42.2", "46.9", "48.5", "50.1", "50.13", "55.4",
                 "62.5", "62.10", "62.14", "62.15", "62.18", "72.5", "73.27", "74.16", "75.22",
                 "75.23", "75.28", "76.5", "77.3", "78.8", "79.3", "80.4", "81.1", "82.4", "83.2",
                 "83.6", "83.7", "83.12", "84.11", "84.20", "85.4", "86.10", "86.12", "87.10",
                 "88.4", "88.11", "88.16", "91.2", "97.1", "98.4", "101.1", "104.22", "104.23",
                 "105.1", "109.9", "109.29", "112.8", "122.11", "127.6", "127.11", "127.13",
                 "128.5", "133.7", "138.1", "139.20", "139.26", "139.35", "148.2", "151.15", "152.4",
                 "153.1", "156.15", "156.17", "156.27", "161.7", "162.3", "163.6", "168.2", "172.8",
                 "173.8", "178.1", "185.1", "186.2", "189.3", "196.7", "196.12", "200.4", "205.6",
                 "206.3", "208.2", "208.3", "209.4", "211.1", "212.10", "212.48", "212.49", "213.2",
                 "213.4", "223.2", "234.18", "237.1", "246.9", "247.3", "307.5", "308.1", "311.6")

# Stations in Lars Roald report from 2002

stats_roald <- c("234.18", "213.2", "209.4", "191.2", "161.7", "151.15", "124.2",
                 "122.11", "122.17", "103.1", "2.32", "2.142", "2.279", "26.26")

stats <- c(stats_fleig, stats_roald)

stats <- c("140.2", "307.7", "122.9", "122.11", "123.31", "124.2", "127.11", "127.13", "307.5", "138.1", "308.1", "139.35", "127.6")



# Read metadata

df_all <- read_excel("../documents/stations_metadata.xlsx")

# Select watersheds of appropriate size

lower_limit <- 300
upper_limit <- 4000

df_all$regine_main <- paste(df_all$regine_area, df_all$main_no, sep = ".")

df_sub <- df_all %>% 
  filter(regine_main %in% stats) %>%
  filter(perc_glacier < 1) %>%
  filter(area_total > lower_limit) %>% 
  filter(area_total < upper_limit)

# Plot results on map

leaflet(data = df_sub) %>% addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~as.character(station_name), label = ~as.character(regine_main))

# Manual selection of stations

stat_select <- c("191.2", "122.11", "2.32", "2.279", "224.1", "2.142", "12.70", "62.5", "22.4")

df_select <- df_all %>% filter(regine_main %in% stat_select)

# Plot results on map

leaflet(data = df_select) %>% addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~as.character(regine_main), label = ~as.character(regine_main))




















