#url to download data
link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#check if zip exists and download if not
if (!file.exists("UCI_HAR_Data.zip")){
        download.file(link,"UCI_HAR_Data.zip", mode = 'wb')
}

#Check if unzipped
if (!file.exists("UCI HAR Dataset")) { 
        unzip("UCI_HAR_Data.zip") 
}

# read all data
features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

train.x <- read.table('./UCI HAR Dataset/train/X_train.txt')

train.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')

train.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

train <-  data.frame(train.subject, train.activity, train.x)
names(train) <- c(c('subject', 'activity'), features)

test.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
test.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
test.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

test <-  data.frame(test.subject, test.activity, test.x)
names(test) <- c(c('subject', 'activity'), features)

# 1 Merge Training and Testing Sets 
master <- rbind(train, test)

#2 Extract only the measurements on the mean and standard deviation for each measurement.
mean_std <- grep('mean|std', colnames(master))
sub_master <- data.sub <- master[,c(1,2,mean_std)]

#3 Uses descriptive activity names to name the activities in the data set
labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
labels <- as.character(labels[,2])
sub_master$activity <- labels[sub_master$activity]

#4  Appropriately labels the data set with descriptive variable names.
new_names <- names(sub_master)
new_names <- gsub("[(][)]", "", new_names)
new_names <- gsub("^t", "TimeDomain_", new_names)
new_names <- gsub("^f", "FrequencyDomain_", new_names)
new_names <- gsub("Acc", "Accelerometer", new_names)
new_names <- gsub("Gyro", "Gyroscope", new_names)
new_names <- gsub("Mag", "Magnitude", new_names)
new_names <- gsub("-mean-", "_Mean_", new_names)
new_names <- gsub("-std-", "_StandardDeviation_", new_names)
new_names <- gsub("-", "_", new_names)
names(sub_master) <- new_names

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
FinalData <- sub_master %>%
        group_by(subject, activity) %>%
        summarise_all(list(mean))

write.table(FinalData, "FinalData.txt", row.name=FALSE)