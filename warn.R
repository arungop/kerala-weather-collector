
# Packages needed

library(tabulizer)
library(tidyverse)
library(lubridate)
library(jsonlite)


# Source data

pdf <- "https://mausam.imd.gov.in/thiruvananthapuram/mcdata/district_rainfall_forecast.pdf"

# Collect data from pdf
warning <- extract_tables(pdf,
                                output = "matrix",
                                pages = c(1,1),
                                area = list(
                                  c(164.24098 , 32.80293, 708.75162 ,550.67989),
                                  c(149.44450,  29.84363, 164.24098, 555.11884  )),
                                guess = FALSE,
                                method = "stream"
)

# Convert both matrix to data.frames
data <- as.data.frame(warning[[1]]) 
header <- as.data.frame(warning[[2]])

# Date as header
data <- data[,-1]

data_tvm <- slice_head(data,n = 1)
 
row_tri <- seq_len(nrow(data)) %% 3  #  Table issues fixed
data_row_tri <- data[row_tri == 0, ] 

# Districts as headers
combined <- rbind(data_tvm, data_row_tri ) %>% 
mutate(V1= c("Thiruvananthapuram","Kollam","Pathanamthitta",
            "Alappuzha","Kottayam","Ernakulam","Idukki",
            "Thrissur","Palakkad","Malappuram","Kozhikode",
            "Wayanad","Kannur","Kasaragode","Lakshadweep") ) 

# Reorder coloumns
combined <- combined[,c(6,1,2,3,4,5)] 


warning_five <- rbind(header,combined)

names(warning_five) <- warning_five[1,]

warning_five <- warning_five[-1,]


# time series
df2 <- data.frame(t(warning_five[-1]))
colnames(df2) <- warning_five[, 1]

# set first coloumn as date

df2 <- cbind(Date = rownames(df2), df2)
rownames(df2) <- 1:nrow(df2)

# Write output
write.csv(warning_five,"./data/weather_warn.csv", row.names = F,quote=F)

write.csv(df2,"./data/weather_warn_ts.csv", row.names = F,quote=F)

#weather_a  <- read_csv("./data/weather_warn.csv") 
#weather_t <-  read_csv("./data/weather_warn_ts.csv")

view(warning_five)
view(df2)



