# - Concatenate strings with paste0 (paste() has a separation " " added).
# - List files within folder using regex to find the correct files.
# - Merge Data Frames into a single one.
# - Read CSV with advanced parameters.
# - Create factors from unique values.
# - Merge (Join) Data Frames.
# - DataFrames Long or Wide using pivot_longer
#
# - List and Merge: https://www.r-bloggers.com/2011/06/merge-all-files-in-a-directory-using-r-into-a-single-dataframe/

# Next Steps: 
# - Calculate the First Derivative:
#   https://stackoverflow.com/questions/14082525/how-to-calculate-first-derivative-of-time-series
#---------------------------------------------------------------
#install.packages("tidyverse")
#install.packages("wesanderson")
install.packages("pspline")
library("ggplot2")
library("tidyr")
library("readr")
#library("tidyverse")
library("purrr")
library("svMisc")
library("wesanderson") # Color Palette
library("pspline")

setwd("~/Documents/R-Scripts/R-LSOF-Analysis")


# -------------------------
# Remove All Objects from 
# Work Space.
# -------------------------
rm(list = ls())

# -------------------------
# Number of top process
# -------------------------
vNumberOfProcess <- 12
vChartRow        <- 3
vChartCol        <- 4


# -------------------------
# List files and merge them 
# in a single DF.
# -------------------------
file_list <- list.files("./Data/", pattern= '^lsof.')

# -----------------
# Merge Files -----
# -----------------
rm(df.Data)
for (file in file_list){
  
  file <- paste0("./Data/", file)
  
  # if the merged dataset doesn't exist, create it
  if (!exists("df.Data")){
    df.Data <- read.csv(file, 
                        skip=0,
                        header = FALSE,
                        sep = " ",
                        strip.white=TRUE,
                        blank.lines.skip=TRUE,
                        col.names=c("DATE_TIME", "V2", "PROCESS", "COUNT")
    )
    df.Data$V2 <- NULL
  } else {
    df.DataTemp <- read.csv(file, 
                            skip=0,
                            header = FALSE,
                            sep = " ",
                            strip.white=TRUE,
                            blank.lines.skip=TRUE,
                            col.names=c("DATE_TIME", "V2", "PROCESS", "COUNT")
    )
    df.DataTemp$V2 <- NULL
    
    df.Data <- rbind(df.Data, df.DataTemp)
    rm(df.DataTemp)
  }
  
  # if the merged dataset does exist, append to it
  #if (exists("df.Data")){
  #  df.DataTemp <- read.csv(file, 
  #                          skip=0,
  #                          header = FALSE,
  #                          sep = " ",
  #                          strip.white=TRUE,
  #                          blank.lines.skip=TRUE,
  #                          col.names=c("DATE_TIME", "V2", "PROCESS", "COUNT")
  #  )
  #  df.DataTemp$V2 <- NULL
  #  
  #  df.Data <- rbind(df.Data, df.DataTemp)
  #  rm(df.DataTemp)
  #}
}

# ------------------------
# Check data frame status
# ------------------------
typeof(df.Data)
str(df.Data)
class(df.Data)
head(df.Data)

# ------------------------
# Check data frame status
# ------------------------
df.Data$DateTime <- as.POSIXct(df.Data$DATE_TIME, tz='', '%Y-%m-%d_%H-%M')
df.Data$DATE_TIME<- NULL

# --------------------------
# Create factor for PROCESS
# --------------------------
levels(df.Data$PROCESS) <- unique(df.Data$PROCESS)


# --------------------------------------
# Transpose values from Lines to Columns
# --------------------------------------

# 1. Create Data Frame with distinct DateTime.
df.DataTranspose           <- as.data.frame(unique(df.Data$DateTime))
colnames(df.DataTranspose) <- c('DateTime')

head(df.DataTranspose)
head(df.Data)

# 2. Loop to run after all PROCESS levels.
for (i in 1:length(levels(df.Data$PROCESS))) {
  
  # 3. Merge a single process with df.DataTranspose, 
  #    using DateTime as key.
  df.DataTranspose <- merge(df.DataTranspose,
                            df.Data[df.Data$PROCESS==levels(df.Data$PROCESS)[i], c('DateTime', 'COUNT')],
                            by="DateTime",
                            all.x=TRUE,
                            all.y=FALSE
  )
  
  # 4. Rename the column COUNT created in 3 with the correct process name.
  colnames(df.DataTranspose)[i+1] = levels(df.Data$PROCESS)[i]
  
  # 5. Print ProgressBar  (svMisc )
  progress(i, progress.bar=TRUE)
  Sys.sleep(0.01)
  
  #if (i == 1 ){
  #  break
  #}
}


# --------------------------------------
# Calculate the process with largest 
# variance 
# --------------------------------------
vDifferece <- NULL
for (i in 2:length(df.DataTranspose)) {
  
  if (!exists("v.Difference")){
    v.Difference <- c(max(df.DataTranspose[i]) - min(df.DataTranspose[i]))
    names(v.Difference)[i-1] <- colnames(df.DataTranspose)[i]
    
  } else {
    v.Difference <- c(v.Difference, max(df.DataTranspose[i]) - min(df.DataTranspose[i]))
    names(v.Difference)[i-1] <- colnames(df.DataTranspose)[i]
  }
  
}


v.DidfferenceTop10 <- head(sort(v.Difference, decreasing=TRUE), vNumberOfProcess)

# -- Remove columns for better analysis
#v.DidfferenceTop10$sshd <- NULL
#v.DidfferenceTop10$`sftp-serv` <- NULL


v.DidfferenceTop10

# Check point --
str(v.DidfferenceTop10)
str(v.Difference)
names(v.DidfferenceTop10)


# ---------------------------------------------
# df.DataTransposeTop10
# ---------------------
# DataFrame to list the top 10 most significant
# Process
# ----------------------------------------------
df.DataTransposeTop10 <- df.DataTranspose[c("DateTime", names(v.DidfferenceTop10))]
df.DataTransposeTop10

# ---------------------------------------------
# df.DataTop10
# ------------
# Convert df.DataTransposeTop10 from Wide to Long
# format using "pivot_longer" funciont
# ----------------------------------------------
df.DataTop10 <- df.DataTransposeTop10 %>% pivot_longer(cols=c(names(v.DidfferenceTop10)),
                                                       names_to="Process",
                                                       values_to="Values")

df.DataTop10
df.DataTransposeTop10

# ---------------------------------------------
# Print Chart
# ------------
# Show chart line for each process using face_wrap.
# ----------------------------------------------
ggplot(df.DataTop10, aes(x=DateTime, y=Values)) +
  geom_line(aes(color=Process), linewidth=1) + 
  scale_fill_manual(values=wes_palette(n=3, name="Cavalcanti1")) +
  #geom_text(aes(x=DateTime, y=Values,label=Values),vjust=-0.25) + # -- Print labels
  facet_wrap(~Process, scales="free_y")
#scale_fill_brewer(palette="Dark2")
#scale_color_viridis_d() +
#scale_color_hue(l=10, c=25) 


# ---------------------------------------------
# Prediction 
# -----------
# Show plot for each Process and its prediction
# ----------------------------------------------
#install.packages("pspline")
#library("pspline")


# -- Test for 1 variable --
#par(mfrow=c(1,1))
#plot(df.DataTransposeTop10$DateTime, df.DataTransposeTop10$voice_con, main = "Derivative", ann=FALSE, xaxt='n')
#temp.spl <- sm.spline(df.DataTransposeTop10$DateTime, df.DataTransposeTop10$voice_con)
#lines(temp.spl, col = "blue")
#lines(sm.spline(df.DataTransposeTop10$DateTime, df.DataTransposeTop10$voice_con, df=10), lty=2, col = "red")
#axis(1, df.DataTransposeTop10$DateTime, format(df.DataTransposeTop10$DateTime, "%d/%m\n%H"), cex.axis = .7)

# ---------------------------------------------
# Plot prediction:
# ---------------
# Plot 3 by 4 rows using par() function
#
# ---------------------------------------------
par(mfrow=c(vChartRow, vChartCol))
for (i in 2:length(df.DataTransposeTop10)) {
  print(colnames(df.DataTransposeTop10)[i])
  # Do not plot "DateTime" column.
  if (colnames(df.DataTransposeTop10)[i] != "DateTime"){
    
    # Plot dots for raw values
    plot(df.DataTransposeTop10$DateTime, 
         df.DataTransposeTop10[, i], 
         main=colnames(df.DataTransposeTop10)[i], 
         xaxt='n')  # -- Remove labels on x-axis
    
    # Calculate the prediction and plot.
    lines(sm.spline(df.DataTransposeTop10$DateTime, df.DataTransposeTop10[, i]), col = "blue")
    # Plot prediction with Degree Of Freedom = 10
    lines(sm.spline(df.DataTransposeTop10$DateTime, df.DataTransposeTop10[, i], df=10), lty=2, col = "red")
    axis(1, df.DataTransposeTop10$DateTime, format(df.DataTransposeTop10$DateTime, "%d/%m\n%H"), cex.axis = .7)
  }
}



