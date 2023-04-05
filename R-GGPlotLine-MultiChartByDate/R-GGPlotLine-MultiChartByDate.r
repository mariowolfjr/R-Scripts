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
suppressPackageStartupMessages({
  library("padr")
  library("ggplot2")
  library("lubridate")
  library("dplyr")
})

# Check the Locale 
Sys.getlocale("LC_TIME")

# Load file
df.Data <- read.csv("Auxiliar/Calls_2.csv")

# Create column DateTime2 as POSIXct format.
df.Data$DateTime2 <- as.POSIXct(df.Data$DateTime, tz = "", '%Y-%m-%d %H:%M')

# Pad time series by hour.
df.DataPad <- pad(df.Data, start_val = as.POSIXct("2023-03-01 00:00:00", tz = "", '%Y-%m-%d %H:%M'))
# Convert NA added by padding to 0
df.DataPad[is.na(df.DataPad)] = 0

# Create Auxiliar columns
# - Group: defines each chart to be created
# - xValues: is the values presented on x Axis
# - Categories: Defines the lines within each Group
df.Data$Group      <- wday(df.Data$DateTime2, label=TRUE, abbr=TRUE, locale="en_US.UTF-8")
df.Data$xAxis      <- hour(df.Data$DateTime2)
df.Data$Categories <- week(df.Data$DateTime2)

# Convert columns to Factors
df.Data$Categories <- as.factor(df.Data$Categories)

# Remove columns not used
df.Data$DateTime  <- NULL
df.Data$DateTime2 <- NULL

# Checking values
str(df.Data)
levels(df.Data$Categories)
levels(df.Data$Group)
length(levels(df.Data$Group))


head(df.Data)
head(t(df.Data))

head(filter(df.Data, Group == "Wed"))
head(t(filter(df.Data, Group == "Wed")))


df.Wed <- filter(df.Data, Group == "Wed")

df.Temp <- data.frame(filter(df.Wed$Value, Categories == 9))


df.Wed[, df.Wed$Categories == 9]

# Create list of Dataframes for Groups
ListOfGroup <- list()
for (iGroups in 1:length(levels(df.Data$Group))) {
  print(levels(df.Data$Group)[iGroups])
  
  
  
  # Transpose Categories to Columns
  for (iCategories in 1:length(levels(df.Data$Categories))){
    df.Temp[] <- cbind(df.Temp, c)
    
    
  }
   
  
  ListOfGroup[[length(ListOfGroup)+1]] <- filter(df.Data, Group == levels(df.Data$Group)[i])

  
} 

head(ListOfGroup)

#### https://www.tutorialspoint.com/how-to-add-a-data-frame-inside-a-list-in-r ---
#List1[[length(List1)+1]]<−df1
#List1


