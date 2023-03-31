# - Date Time Handling
# - Padding timeseries by hour
# - Converting NA to 0
# - teste

#https://statisticsglobe.com/insert-rows-for-missing-dates-in-r
#---------------------------------------------------------------
#install.packages("padr")
library("padr")
library("ggplot2")

df.Data <- read.csv("R-GGPlot-Line/Calls_2.csv")

df.Data$DateTime2 <- as.POSIXct(df.Data$DateTime, tz = "", '%Y-%m-%d %H:%M')
head(df.Data)

df.Data$DateTime <- NULL
df.Data$Time     <- NULL
df.DataPad <- pad(df.Data, start_val = as.POSIXct("2023-03-01 00:00:00", tz = "", '%Y-%m-%d %H:%M'))

head(df.DataPad)

str(df.DataPad)

# Convert NA to 0
df.DataPad[is.na(df.DataPad)] = 0

#df.DataPad$Date <- as.Date(df.DataPad$DateTime2)


ggplot(data=df.DataPad, aes(DateTime2, Value)) + geom_line() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_datetime(date_breaks = "day" , date_labels = "%Y-%m-%d")


