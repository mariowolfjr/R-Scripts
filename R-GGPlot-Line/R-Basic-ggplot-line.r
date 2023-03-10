# - Date Time Handling
# - Padding timeseries by hour
# - Converting NA to 0
#

#https://statisticsglobe.com/insert-rows-for-missing-dates-in-r
#---------------------------------------------------------------
#install.packages("padr")
library("padr")
library("ggplot2")

df.Data <- read.csv("28.CALL-PROFILE/temp.csv")
df.Data$DateTime2 <- as.POSIXct(df.Data$DateTime, tz = "", '%Y-%m-%d %H:%M')

head(df.Data)

df.Data$DateTime <- NULL
df.Data$Time     <- NULL
df.DataPad <- pad(df.Data, start_val = as.POSIXct("2023-02-01 00:00:00", tz = "", '%Y-%m-%d %H:%M'))

head(df.DataPad)


# Convert NA to 0
df.DataPad[is.na(df.DataPad)] = 0
ggplot(data=df.DataPad, aes(DateTime2, Calls)) + geom_line() 
