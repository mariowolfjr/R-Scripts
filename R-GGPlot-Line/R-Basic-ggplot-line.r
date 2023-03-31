# R-Basic-ggplot-line.r
# ---------------------
# This script shows:
# - How to Handling DateTime on ggplot (as.POSIXct).
# - Padding the time series using "0" by hour (pad command).
# - Converting NA to 0
# 
# Based on:
# https://statisticsglobe.com/insert-rows-for-missing-dates-in-r
#---------------------------------------------------------------
library("padr")
library("ggplot2")

# Load file
df.Data <- read.csv("R-GGPlot-Line/Calls_2.csv")

# Create column DateTime2 as POSIXct format.
df.Data$DateTime2 <- as.POSIXct(df.Data$DateTime, tz = "", '%Y-%m-%d %H:%M')

# Delete unused columns.
df.Data$DateTime <- NULL
df.Data$Time     <- NULL

# Pad time series by hour.
df.DataPad <- pad(df.Data, start_val = as.POSIXct("2023-03-01 00:00:00", tz = "", '%Y-%m-%d %H:%M'))

head(df.DataPad)
str(df.DataPad)

# Convert NA added by padding to 0
df.DataPad[is.na(df.DataPad)] = 0

# Simple line plot
# - Adjusting legend 
# - Tilting X values in 45 degrees.
ggplot(data=df.DataPad, aes(DateTime2, Value)) + geom_line() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_datetime(date_breaks = "day" , date_labels = "%Y-%m-%d")


