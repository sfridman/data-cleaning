# Clean Course - Project - run_analysis.R
# Git with CodeBook.md and README.md

# Data - https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
# 70% train 30% test - randomally - 30 participants
# 50Hz samples, Samsung II waist doing actovotoes, Gyro + Accelerometer
# Set of features, and multiple variables per feature [-1,1] range
# 17 features (t = time, f = frequency) some (8) with XYZ components X 17 variables

# Step 0 - Data Definitions 

dataDir <- "UCI HAR Dataset"
trainStr <- "train"
testStr <- "test"
subjectStr <- "subject_"
extStr <- ".txt"

featuresFile <- "features.txt"              # Features Description
activityLabelsFile <- "activity_labels.txt" # Activity Index

features <- read.table(file.path(dataDir, featuresFile), col.names = c("Index", "Feature"), stringsAsFactors = FALSE)
activities <- read.table(file.path(dataDir, activityLabelsFile), col.names = c("Index", "Activity"), stringsAsFactors = FALSE)

# subject, y = activity, values = features 
readData <- function(str) {
  subject <- read.table(file.path(dataDir, str, paste(subjectStr, str, extStr, sep = "")),
    col.names = "Subject")
  y <- read.table(file.path(dataDir, str, paste("y_", str, extStr, sep = "")), 
    col.names = "Activity")
  values <- read.table(file.path(dataDir, str, paste("X_", str, extStr, sep = "")),
    col.names = features$Feature)
  cbind(values, subject, y)
}

# Step 1 - Merge Training and Test 

data <- rbind(readData(trainStr), readData(testStr))

# Step 2 - Extract means and std 

data <- data[, c(grep("\\-mean\\(\\)|\\-std\\(\\)", features$Feature), 
          which(colnames(data) %in% c("Subject", "Activity")))]

# Step 3 - Descriptive activity names + Factorization 

data$Activity <- factor(data$Activity, levels = activities$Index, labels = activities$Activity)
data$Subject <- factor(data$Subject)

# Step 4 - Description variable names

names(data) <- sub("\\.\\.", "", names(data))

# Step 5 - Tidy data with Average of each variable for each activity / subject

library(dplyr)
tidy <- data %>% 
  group_by(Activity, Subject) %>%
  summarise_each(funs(mean)) 

write.table(tidy, file = "tidy.txt", append = FALSE, row.names = FALSE)
# debug_tidy <- read.table("tidy.txt")

# Step 6 - Make a codebook

ds <- data.set(tidy)
ds <- within(ds, {
  description(tidy.Activity) <- "Activity of subject for the measured features"
  description(tidy.Subject) <- "Test and Train subjects, identified by a factor 1-30"
})

Write(codebook(ds), file = "codebook.md", append = FALSE)