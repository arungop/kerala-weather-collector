 # Packages needed

library(tabulizer)
library(tidyverse)
library(lubridate)
library(jsonlite)

# Source file (imd tvm)

today <- "https://mausam.imd.gov.in/thiruvananthapuram/mcdata/TodaysWeather.pdf"

# base data
weather_a  <- read_csv("./data/weather_accum.csv") 
  
# Collect data from pdf
weather_today <- extract_tables(today,
                                output = "matrix",
                                pages = c(1,1),
                                area = list(
                                  c(256.3329, 189.7373, 532.5446, 649.0439),
                                  c(173.6786, 395.8498, 190.4187 ,647.9977 )),
                                guess = FALSE,
)

# Which date ?
date <- as.data.frame(weather_today[[2]]) %>% 
  `colnames<-`(c("Date")) 
# repeat date value 15 times to match station values & add index number
date <-   do.call("rbind", replicate(
    15, date, simplify = FALSE)) %>% 
  mutate(id = row_number()) 
  
# main data frame
daily <- as.data.frame(weather_today[[1]]) %>% 
  `colnames<-`(c("Station_Index_Number","Maximum Temperature (°C)",
                 "Minimum Temperature (°C)","Rainfall (mm)"))%>% 
  mutate(id = row_number()) 

# Merge data with date
weather_daily <- merge(x = date, y = daily, by = "id") %>% 
  subset(,select= -c(id)) %>% 
  distinct()

# Combine base data and scrapped data
Daily_combined <- rbind(weather_daily, weather_a ) %>%  # Rbind to append scrapped data
                   distinct(Station_Index_Number,Date,.keep_all = TRUE)

# Write output
write.csv(Daily_combined,"./data/weather_accum.csv", row.names = F,quote=F)
write_json(Daily_combined,"./data/weather_accum.json", sep="")


#view(Daily_combined)



