#Download the data
library(data.table)
url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url,'./UCI HAR Dataset.zip', mode = 'wb')
unzip("UCI HAR Dataset.zip", exdir = getwd())

#Bring the different data sets in to R
#Features
features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

#Training Data Set - Subjec_train, X_train and y_train
train.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')
train.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
train.x <- read.table('./UCI HAR Dataset/train/X_train.txt')
#Make One table
train <-  data.frame(train.subject, train.activity, train.x)
#Rename
names(train) <- c(c('subject', 'activity'), features)

#Test data set - x test, y activity and subject test
test.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
test.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
test.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')
#Make one table
test <-  data.frame(test.subject, test.activity, test.x)
#Rename
names(test) <- c(c('subject', 'activity'), features)

#Merges the training and the test sets to create one data set.
AllData <- rbind(train, test)

#Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_std.select <- grep('mean|std', features)
data.sub <- AllData[,c(1,2,mean_std.select + 2)]

#Uses descriptive activity names to name the activities in the data set
activity.labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.labels <- as.character(activity.labels[,2])
data.sub$activity <- activity.labels[data.sub$activity]

#Appropriately labels the data set with descriptive variable names. 
#Create new name variable
nameNew <- names(data.sub)
nameNew <- gsub("[(][)]", "", nameNew)
nameNew <- gsub("^t", "TimeDomain_",nameNew)
nameNew <- gsub("^f", "FrequencyDomain_", nameNew)
nameNew <- gsub("Acc", "Accelerometer", nameNew)
nameNew <- gsub("Gyro", "Gyroscope",nameNew)
nameNew <- gsub("Mag", "Magnitude", nameNew)
nameNew<- gsub("-mean-", "_Mean_", nameNew)
nameNew <- gsub("-std-", "_StandardDeviation_", nameNew)
nameNew <- gsub("-", "_", nameNew)
#Set the names to be the string formatted
names(data.sub) <- nameNew

#From the data set in step 4, creates a second, independent tidy data set with
#the average of each variable for each activity and each subject.
tidyData <- aggregate(data.sub[,3:81], by = list(activity = data.sub$activity, subject = data.sub$subject),FUN = mean)
write.table(x = tidyData, file = "tidyData.txt", row.names = FALSE)