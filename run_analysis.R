# Download Dataset
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# unzip the Dataset
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

# read the useful data file 
SubjectTrain <- read.table(file.path(path_rf,"train","subject_train.txt"),header = FALSE)
SubjectTest <- read.table(file.path(path_rf,"test","subject_test.txt"),header = FALSE)

DataTrain <- read.table(file.path(path_rf,"train","X_train.txt"),header = FALSE)
DataTest <- read.table(file.path(path_rf,"test","X_test.txt"),header = FALSE)

LabelTrain <- read.table(file.path(path_rf, "train","y_train.txt"),header = FALSE)
LabelTest <- read.table(file.path(path_rf, "test","y_test.txt"),header = FALSE)

# Analyse the structure of the datasets
str(SubjectTrain)
str(SubjectTest)
str(DataTrain)
str(DataTest)
str(LabelTrain)
str(LabelTest)

# Merge the train set and test set
Subject <- rbind(SubjectTrain,SubjectTest)
Data <- rbind(DataTrain,DataTest)
Label <- rbind(LabelTrain,LabelTest)

# Set names to the variables
# According to the readme, the features.txt contains the indication of data's means
dataName <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(Data) <- dataName[,2]
names(Subject) <- c("subject")
names(Label) <- c("Label")

## Merge columns
Data_tide <- cbind(Label,Subject,Data)
write.table(Data_tide, file = "tidyData.txt",row.name = FALSE ) 

## Extracts only the measurements on the mean and standard deviation for each measurement. 

# Extract names with means() or std()
subDataNames <- dataName$V2[grep("mean\\(\\)|std\\(\\)",dataName$V2)]
# Subset data
selectedNames <- c(as.character(subDataNames),"subject","Label")
subData <- subset(Data_tide, select = selectedNames)

## Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
names(activityLabels) <- c("Label","Activity")

Data_tide<- merge(activityLabels, Data_tide , by="Label", all.x=TRUE)


## Appropriately lables the data set with descriptive variable names.
names(Data_tide)<-gsub("^t", "time", names(Data_tide))
names(Data_tide)<-gsub("^f", "frequency", names(Data_tide))
names(Data_tide)<-gsub("Acc", "Accelerometer", names(Data_tide))
names(Data_tide)<-gsub("Gyro", "Gyroscope", names(Data_tide))
names(Data_tide)<-gsub("Mag", "Magnitude", names(Data_tide))
names(Data_tide)<-gsub("BodyBody", "Body", names(Data_tide))

names(Data_tide)


## Creates a second, independent tidy dataset and output it

library(plyr)
Data2<-aggregate(. ~subject + Label, Data_tide, mean)
Data2<-Data2[order(Data2$subject,Data2$Label),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

