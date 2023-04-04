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
library("lubridate")

# Check the Locale 
Sys.getlocale("LC_TIME")

# Load file
df.Data <- read.csv("Auxiliar/Calls_2.csv")


# Create column DateTime2 as POSIXct format.
df.Data$DateTime2 <- as.POSIXct(df.Data$DateTime, tz = "", '%Y-%m-%d %H:%M')
df.Data$DayOfWeek <- wday(df.Data$DateTime, label=TRUE, abbr=TRUE, locale="en_US.UTF-8")



