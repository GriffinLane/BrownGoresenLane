#import libraries
library(dplyr)
library(ggplot2)
library(plyr)
library(tidyr)
library(randomForest)
# import data set
setwd("~/Desktop/MSDS 7330/Project/BrownGoresenLane")
movieData <- read.csv("./Movies.csv")
#########################################################
#            CLEANING NUMERICAL VARIABLES               #
#########################################################
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
# We can see there are NA values in Run time
apply(movieData, 2, function(x) any(is.na(x)))
#There are only 25 NA's so we will delete these observations
movieData <- na.omit(movieData)
#########################################################
#                CLEANING CATEGORICAL                   #
#########################################################
#### Looking at Release Date ####
summary(movieData$release_date)
#Dates are broken up into yyyy-mm-dd
#We will create seperate columns for month and year and delete day
movieData <- separate(movieData, release_date, c("release_year", "release_month"), sep = "-", remove = TRUE,convert = FALSE, extra = "drop")


#### Looking at Cast Variable ####
summary(movieData$cast)
#Cast contains three actor names
#We will split into three variables and if blank or NA we will change to None
movieData <- separate(movieData, cast, c("Cast1", "Cast2", "Cast3"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$Cast1 <- ifelse(movieData$Cast1 != "", as.character(movieData$Cast1), "None")
movieData$Cast2 <- ifelse(is.na(movieData$Cast2), "None", as.character(movieData$Cast2))
movieData$Cast3 <- ifelse(is.na(movieData$Cast3), "None", as.character(movieData$Cast3))
#Now we want to find the top five actors in each 
cast1Count <- (count(movieData$Cast1))
cast1Count <- arrange(cast1Count,-freq)
cast1Count<- cast1Count[1:10,]
cast2Count <- (count(movieData$Cast2))
cast2Count <- arrange(cast2Count,-freq)
cast2Count<- cast2Count[1:10,]
cast3Count <- (count(movieData$Cast3))
cast3Count <- arrange(cast3Count,-freq)
cast3Count<- cast3Count[1:10,]
head(cast1Count, 10)
head(cast2Count, 10)
head(cast3Count, 10)
#Plot on Bar Graph
ggplot(cast1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(cast2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(cast3Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Get top actors in each cast column
TopTenActors1 <- c("Robert De Niro" , "None", "Clint Eastwood", "Tom Hanks", "John Travolta", "Bruce Willis", "Nicolas Cage" , "Sylvester Stallone", "Denzel Washington", "Johnny Depp", "Al Pacino")
TopTenActors2 <- c("Gene Hackman", "Diane Keaton", "Morgan Freeman", "Eddie Murphy", "Ewan McGregor", "Meg Ryan", "Robert Downey Jr.", "Angelina Jolie" , "Jeff Daniels", "None")
TopTenActors3 <- c("None", "Cameron Diaz", "Dennis Hopper", "Christopher Walken", "Joe Pesci", "Kelly Preston", "Robert Duvall" , "Burt Young" , "DeForest Kelley" , "Don Cheadle")
#Change Cast in Data Set
movieData <- transform(movieData, Cast1 = ifelse(Cast1 %in% TopTenActors1, as.character(Cast1), "Other"))
movieData <- transform(movieData, Cast2 = ifelse(Cast2 %in% TopTenActors2, as.character(Cast2), "Other"))
movieData <- transform(movieData, Cast3 = ifelse(Cast3 %in% TopTenActors3, as.character(Cast3), "Other"))


#### Looking at Producer Variable #### 
summary(movieData$producer)
#Cast contains three actor names
#We will split into three variables and if blank or NA we will change to None
movieData <- separate(movieData, producer, c("producer1", "producer2", "producer3"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$producer1 <- ifelse(movieData$producer1 != "", as.character(movieData$producer1), "None")
movieData$producer2 <- ifelse(is.na(movieData$producer2), "None", as.character(movieData$producer2))
movieData$producer3 <- ifelse(is.na(movieData$producer3), "None", as.character(movieData$producer3))
#Now we want to find the top producers in each 
producer1Count <- (count(movieData$producer1))
producer1Count <- arrange(producer1Count,-freq)
producer1Count<- producer1Count[1:10,]
producer2Count <- (count(movieData$producer2))
producer2Count <- arrange(producer2Count,-freq)
producer2Count<- producer2Count[1:10,]
producer3Count <- (count(movieData$producer3))
producer3Count <- arrange(producer3Count,-freq)
producer3Count<- producer3Count[1:10,]
head(producer1Count, 10)
head(producer2Count, 10)
head(producer3Count, 10)
#Plot on Bar Graph
ggplot(producer1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(producer2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(producer3Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Get top actors in each cast column
TopTenProducer1 <- c("Bruce Berman" , "None", "Gary Barber", "Tim Bevan", "Jerry Bruckheimer", "Judd Apatow", "Barry Bernardi" , "Kathleen Kennedy", "Ashok Amritraj", "Clint Eastwood")
TopTenProducer2 <- c("None", "Roger Birnbaum", "John Hughes", "Kathleen Kennedy", "Bruce Berman", "Frank Marshall", "Brian Grazer", "Charles H. Joffe" , "Michael De Luca", "Yoram Globus")
TopTenProducer3 <- c("None", "Toby Emmerich", "Brian Grazer", "John Davis", "Kathleen Kennedy", "Frank Marshall", "Lawrence Gordon" , "Menahem Golan" , "Gary Lucchesi" , "Roger Birnbaum")
#Change Cast in Data Set
movieData <- transform(movieData, producer1 = ifelse(producer1 %in% TopTenProducer1, as.character(producer1), "Other"))
movieData <- transform(movieData, producer2 = ifelse(producer2 %in% TopTenProducer2, as.character(producer2), "Other"))
movieData <- transform(movieData, producer3 = ifelse(producer3 %in% TopTenProducer3, as.character(producer3), "Other"))


#### Now look at writer Variable #### 
summary(movieData$writer)
#Cast contains three actor names
#We will split into three variables and if blank or NA we will change to None
movieData <- separate(movieData, writer, c("writer1", "writer2", "writer3"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$writer1 <- ifelse(movieData$writer1 != "", as.character(movieData$writer1), "None")
movieData$writer2 <- ifelse(is.na(movieData$writer2), "None", as.character(movieData$writer2))
movieData$writer3 <- ifelse(is.na(movieData$writer3), "None", as.character(movieData$writer3))
#Now we want to find the top producers in each 
writer1Count <- (count(movieData$writer1))
writer1Count <- arrange(writer1Count,-freq)
writer1Count<- writer1Count[1:10,]
writer2Count <- (count(movieData$writer2))
writer2Count <- arrange(writer2Count,-freq)
writer2Count<- writer2Count[1:10,]
writer3Count <- (count(movieData$writer3))
writer3Count <- arrange(writer3Count,-freq)
writer3Count<- writer3Count[1:10,]
head(writer1Count, 10)
head(writer2Count, 10)
head(writer3Count, 10)
#Plot on Bar Graph
ggplot(writer1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(writer2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(writer3Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Get top actors in each cast column
TopTenWriter1 <- c("None" , "John Hughes", "Stephen King", "Woody Allen", "Michael Crichton", "Gene Roddenberry", "Wes Craven" , "Brian Helgeland", "Neal Israel", "James Cameron")
TopTenWriter2 <- c("None", "Pat Proft", "David Koepp", "Francis Ford Coppola", "John Carpenter", "Akiva Goldsman", "William Goldman", "Babaloo Mandel" , "Eric Roth", "Ethan Coen")
TopTenWriter3 <- c("None", "Ian Fleming", "Bobby Farrelly")
#Change Cast in Data Set
movieData <- transform(movieData, writer1 = ifelse(writer1 %in% TopTenWriter1, as.character(writer1), "Other"))
movieData <- transform(movieData, writer2 = ifelse(writer2 %in% TopTenWriter2, as.character(writer2), "Other"))
movieData <- transform(movieData, writer3 = ifelse(writer3 %in% TopTenWriter3, as.character(writer3), "Other"))


#### Looking at Director Variable #### 
summary(movieData$director)
#Cast contains three actor names
#We will split into three variables and if blank or NA we will change to None
movieData <- separate(movieData, director, c("director1"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$director1 <- ifelse(movieData$director1 != "", as.character(movieData$director1), "None")
#Now we want to find the top producers in each 
director1Count <- (count(movieData$director1))
director1Count <- arrange(director1Count,-freq)
director1Count<- director1Count[1:10,]
head(director1Count, 10)
#Plot on Bar Graph
ggplot(director1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Get top actors in each cast column
TopFivedirector <- c("Steven Spielberg" , "Clint Eastwood", "Alfred Hitchcock", "Woody Allen", "None")
#Change Cast in Data Set
movieData <- transform(movieData, director1 = ifelse(director1 %in% TopFivedirector, as.character(director1), "Other"))

#### Looking at genres #### 
summary(movieData$genres)
#Cast contains three actor names
#We will split into three variables and if blank or NA we will change to None
movieData <- separate(movieData, genres, c("genre1", "genre2"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$genre1 <- ifelse(movieData$genre1 != "", as.character(movieData$genre1), "None")
movieData$genre2 <- ifelse(is.na(movieData$genre2), "None", as.character(movieData$genre2))
#Now we want to find the top producers in each 
genre1Count <- (count(movieData$genre1))
genre1Count <- arrange(genre1Count,-freq)
genre1Count<- genre1Count[1:10,]
genre2Count <- (count(movieData$genre2))
genre2Count <- arrange(genre2Count,-freq)
genre2Count<- genre2Count[1:10,]
head(genre1Count, 10)
head(genre2Count, 10)
#Plot on Bar Graph
ggplot(genre1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(genre2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()


#### Looking at Production Company #### 
summary(movieData$production_companies)
#Production Company contains many production companies; we will pull top two
#We will split into two variables and if blank or NA we will change to None
movieData <- separate(movieData, production_companies, c("production_company1", "production_company2"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$production_company1 <- ifelse(movieData$production_company1 != "", as.character(movieData$production_company1), "None")
movieData$production_company2 <- ifelse(is.na(movieData$production_company2), "None", as.character(movieData$production_company2))
#Now we want to find the top production companies in each 
production_company1Count <- (count(movieData$production_company1))
production_company1Count <- arrange(production_company1Count,-freq)
production_company1Count<- production_company1Count[1:10,]
production_company2Count <- (count(movieData$production_company2))
production_company2Count <- arrange(production_company2Count,-freq)
production_company2Count<- production_company2Count[1:10,]
head(production_company1Count, 10)
head(production_company2Count, 10)
#Plot on Bar Graph
ggplot(production_company1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(production_company2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Get top ten production companies in each
TopTenproduction_company1 <- c("Paramount" , "Universal Pictures", "Columbia Pictures", "New Line Cinema", "None")
TopTenproduction_company2 <- c("None", "Universal Pictures", "Warner Bros. Pictures", "Columbia Pictures", "20th Century Fox")
#Change Production Company in Data Set
movieData <- transform(movieData, production_company1 = ifelse(production_company1 %in% TopTenproduction_company1, as.character(production_company1), "Other"))
movieData <- transform(movieData, production_company2 = ifelse(production_company2 %in% TopTenproduction_company2, as.character(production_company2), "Other"))

#### Looking at Production Countries #### 
summary(movieData$production_countries)
#Production Company contains many production companies; we will pull top two
#We will split into two variables and if blank or NA we will change to None
movieData <- separate(movieData, production_countries, c("production_country1", "production_country2"), sep = ",", remove = TRUE,convert = FALSE, extra = "drop")
movieData$production_country1 <- ifelse(movieData$production_country1 != "", as.character(movieData$production_country1), "None")
movieData$production_country2 <- ifelse(is.na(movieData$production_country2), "None", as.character(movieData$production_country2))
#Now we want to find the top production companies in each 
production_country1Count <- (count(movieData$production_country1))
production_country1Count <- arrange(production_country1Count,-freq)
production_country1Count<- production_country1Count[1:10,]
production_country2Count <- (count(movieData$production_country2))
production_country2Count <- arrange(production_country2Count,-freq)
production_country2Count<- production_country2Count[1:10,]
head(production_country1Count, 10)
head(production_country2Count, 10)
#Plot on Bar Graph
ggplot(production_country1Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
ggplot(production_country2Count, aes(reorder(x=x, freq), y=freq)) + geom_bar(stat= "identity") + coord_flip()
# Production_country2 has too many 'None's so we will delete that variable
movieData <- subset(movieData, select = -production_country2)

#### EXPORT CLEANED DATA SET ####
write.csv(movieData, file = "movieData.csv")

#########################################################
#               EXPLORING DATA ANALYSIS                 #
#########################################################
#Exploring Most 

#Vote Average and 



#########################################################
#                     RANDOM FOREST                     #
#########################################################
rf_model <- randomForest(x = as.data.frame(movieClean[,-1]), y = movieClean$revenue , importance = TRUE)
rf_model
varImpPlot(rf_model)
importance(rf_model)
top_rf <- names(tail(sort(importance(rf_model)[,3]),5))


#########################################################
#                   PREDICTING VOTES                    #
#########################################################



