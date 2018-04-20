#import libraries
library(dplyr)
library(ggplot2)
library(plyr)
library(tidyr)
# import data set
setwd("~/Desktop/MSDS 7330/Project/BrownGoresenLane")
movieData <- read.csv("./Movies.csv")
#################### CLEANING DATA ######################
# Subset by movies with revenue information
movieData <- movieData[!(movieData$revenue==0),]
#looking into data
head(movieData)
summary(movieData)
length(movieData2[(movieData$vote_average==0),])
# simple plot of revenue
plot(movieData$revenue)
# Revenue under 1,000 is likely a typo
movieData <- movieData[(movieData$revenue>=1000),]
################## EXPLORING CATEGORICAL VARIABLES ##################
#### looking at directors ####
#Get list of Top Ten Most Common Directors
dirCount <- (count(movieData$director))
dirCount <- arrange(dirCount,-freq)
dirCount<- dirCount[1:10,]
#Plot on Barplot 
ggplot(dirCount, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Keep top three directors, label rest as 'other' to reduce variability
TopThreeDirectors <- c("Steven Spielberg" , " Clint Eastwood", "Alfred Hitchcock")
movieClean <- transform(movieData, director = ifelse(director %in% TopThreeDirectors, as.character(director), "Other"))

#### Looking at producer #### 
#Get Top Ten Most Common Producers
prodCount <- (count(movieData$producer))
prodCount <- arrange(prodCount,-freq)
prodCount<- prodCount[1:10,]
#Plot on Bar Graph
ggplot(prodCount, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
#Keep top three, label rest as 'other'
TopThreeProducers <- c("Alfred Hitchcock", "Walt Disney", "Charles Chaplin")
movieClean <- transform(movieClean, producer = ifelse(producer %in% TopThreeProducers, as.character(producer), "Other"))

#### Looking at writer ####
#Get Top Ten Most Common Writers
writCount <- (count(movieData$writer))
writCount <- arrange(writCount,-freq)
writCount<- writCount[1:10,]
#Plot on Bar Graph
ggplot(writCount, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
#Keep top three, label rest as 'other'
TopThreeWriters <- c("Woody Allen", "John Hughes", "Don Hartman,Frank Butler,Harry Hervey,")
movieClean <- transform(movieClean, writer = ifelse(writer %in% TopThreeWriters, as.character(writer), "Other"))

#### Looking at Release Date ####
summary(movieClean$release_date)
#Dates are broken up into yyyy-mm-dd
#We will create seperate columns for month and year and delete day
movieClean <- separate(movieClean, release_date, c("release_year", "release_month"), sep = "-", remove = TRUE,convert = FALSE, extra = "drop")


#### Looking at Cast Variable ####
summary(movieClean)
#Cast contains three actor names
#We will split into three variables 
movieClean1 <- separate(movieClean, cast, c("Actor1", "Actor2", "Actor3"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
#Now we want to find the top five actors in each 
actor1 <- data.frame(table(movieClean1$Actor1))
actor2 <- data.frame(table(movieClean1$Actor2))
actor3 <- data.frame(table(movieClean1$Actor3))
# Combine them into one data frame
total <- merge(actor1, actor2, by= "Var1", all = TRUE)
total <- merge(total, actor3, by="Var1", all=TRUE)
# Now sum each frequency together
total$grandTotal <- rowSums(total[,c("Freq", "Freq.x", "Freq.y")], na.rm=TRUE)
# Now plot Top 50 most popular actors
total <- arrange(total,-grandTotal)
total<- total[1:50,]
#Plot on Bar Graph
ggplot(total, aes(reorder(x=Var1, grandTotal), y=grandTotal)) + geom_bar(stat= "identity") + coord_flip()


