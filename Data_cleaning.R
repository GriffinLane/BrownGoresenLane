#import libraries
library(dplyr)
library(ggplot2)
library(plyr)
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





############# T-SNE to Reduce Diminsionality ################
install.packages("Rtsne")
library(Rtsne)
colors = rainbow(length(unique(movieData2)))
names(colors) = unique(movieData2)
tsne <- Rtsne(movieData2[,-1], dims = 2, perplexity=30, verbose=TRUE, max_iter = 500)

