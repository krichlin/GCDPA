####################################################################
####################################################################
## run_analysis.R ## Kenneth Richlin ## Getting and Cleaning Data ##
####################################################################
####################################################################

run_analysis <- function() {                   ## This Analysis can be run as a a function.
                                               ## It will return a single frame of tidy data.

## We use plyr for column renaming, and data.table for sorting, for so include them both here.

library(plyr)
library(data.table)


## set current working directory to point to the local flat data files.
## setwd("~/R/GCD/data")

## This submission assumes that the samsung data is already in the current working directory.  


###################################################################################################
## Read in training data set and test data set from their respective files into new data frames. ##
###################################################################################################     


## Read the activity names into a data frame.  
activity_Names <- read.table("activity_labels.txt")

## Read the measurement names into a data frame.
measurement_Names <- read.table("features.txt")

## read the Test Subject data into data frames
subject_Test <-  read.table("test/subject_test.txt")
x_Test <- read.table("test/X_test.txt")
y_Test <- read.table("test/y_test.txt")
   
## (alternatively we could just populate a vector manually with the following line)
## c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")

## read the Training Subject data into data frames
subject_Train <- read.table("train/subject_train.txt")
x_Train <- read.table("train/X_train.txt")
y_Train <- read.table("train/y_train.txt")
     


##################################################################
## Merge the training and test data into a single new data set. ##
##################################################################


## subject_Test and subject_Train get merged into subject_All

subject_All <- merge(subject_Train, subject_Test, all=TRUE)

## x_Train and x_Test get merged into x_All with rbind

x_All <- rbind(x_Train, x_Test)
     
## y_Train and y_Test get merged into y_All with rbind

y_All <- rbind(y_Train, y_Test)

## We are left with five new data frames:  subject_All, x_All and  y_All, measurement_Names, and activity_Names



################################################################################
## Change the names of some of the columns in the data to be more meaningful. ##
################################################################################


## subject_All has a single column with a meaningless name, "V1".  let's change that to the more meaningful "subject"

colnames(subject_All) <- "subject"

## y_All has a single column with a meaningless name, "V1".  Let's change that to the more meaningful "activity"

colnames(y_All) <- "activity"

## We are done renaming and relabeling things for the moment.  




##########################################################################################################
## Merge the the three datasets, subject_All, x_All, and y_All into a new, singular dataframe all_Data  ##
##########################################################################################################


## Let's use cbind() add subject_All and y_All to x_All, as two brand new additional columns
## and store it in a new data frame called "all_Data"

all_Data <- cbind(subject_All, y_All, x_All)


##############################################################################
## Provide meaningful column names to x_All, from the Features.txt file.    ##
##############################################################################

## The columnnames for the measurements in "x_All" are still meaningless .. "V1" "V2" "V3"... etc...
## To fix this, we must put the meaningful column names from the "measurement_Names" into the columnnames of "x_All"

feature_List <- measurement_Names[,2]    ## Generate a list of featurenames

## feature_List is of type Factor.  Let's change it to string.

feature_List <- data.frame(lapply(feature_List, as.character), stringsAsFactors=FALSE)

## cycle through the columns in all_Data, and rewrite the column names from measurement_Names

## setnames(x_All, new = measurement_Names)                                ## This line doesn't work. :/

numcol <- ncol(x_All)   ## first get the number of columns (it's 561)
numcol <- numcol + 2    ## add two to account for the aditional columns in all_Data

i <- 3                  ## we start the loop at 3!  We do this to skip the first two columns,
                        ## which are already correctly designated as "subject" and "activity"
                        ## we don't want those two column names to be overwritten.

for(i in 3:numcol) { colnames(all_Data)[i] <-feature_List[i-2] }     ## Add the column names from feature_List to all_Data
                                                                     ## column is -2 to stop from overwriting
                                                                     ## subject and activity.


######################################################################################################################
## To meet Tidy Data requirements, we need to swap in the "activity" strings in place of their indicies in all_Data ##
######################################################################################################################


## all_Data column 2 has them as numbers 1-6.                                
## the activity_Names dataframe has the data we need to decode them.                                       
## Let's replace the digits with the correct strings     
## Swap in activity names by creating a new int vector from all_Data's second column.

act_Names <- (all_Data[,2])

## Next, we change all_Data's "activity" column into character type.

all_Data[,2] <- as.character("5")

## Next, we use act_Names to look up the right string, and save that string in all_Data[,2]

numrows <- nrow(all_Data)   ## Grab the number of rows (it's 10299)

i <- 1

for (i in 1:numrows) {                                                      ## Loop through rows in x_All
     
                  index <-  act_Names[i]                                    ## Lookup act_Names[i], save it in index
                                                                    
                  all_Data[i,2] <- as.character(activity_Names[index,2])    ## cross reference index with activity_Names
                                                                            ## and save the result into all_Data[i,2]
                  
}


## Now that all the columns have meaningful names and we have populated the activity strings,
## Let's identify the columns in all_Data that we want to analyze, and isolate them.
## We want to find the mean and standard deviation for "each measurement"  containing "-mean(" or "-std("

## Let's create a new dataframe that is a subset of all_Data and call it slim_Data
## This dataframe will only grab the columns we are interested in: subject_Index, activity_Index, and the others
## that have the strings "mean()" or "std()"

## Find out which columns have "mean()" or "std()" and store them into new int variables mean_Cols and std_Cols

mean_Cols <- grep(".*-mean\\(.*",feature_List)
std_Cols <- grep(".*-std\\(.*",feature_List)


n <- max(length(mean_Cols), length(std_Cols))  ## make both vectors the same length so we can cbind them
length(mean_Cols) <- n                         ## so we avoid repetition when we cbind.
length(std_Cols) <- n

both_Cols <- as.vector(cbind(mean_Cols,std_Cols))   ## cbind them together into a single, new column
both_Cols <- na.omit(both_Cols)                     ## remove the NA's

len <- length(both_Cols)                            ## grab the column length we want to iterate through
i <- 1                                              ## initialize loop

for(i in 1:len){                             ## Because we added two columns to the front of all_Data, we need to adjust 
     both_Cols[i] <- ((both_Cols[i]) + 2)    ## the column index accordingly.
}                                            ## It means adding an offset value of 2 to everything in both_Cols.
                                        

onetwo <- as.numeric(c("1","2"))            ## Let's add column 1 and 2 back in.
all_Cols <- c(onetwo,both_Cols)             ## by concatenating it together into a new vector all_Cols
all_Cols <- sort(all_Cols)                  ## ...  and then sort them to the front.

## We now have a vector that contains all the columns we are interested in keeping!
## Next, select those columns from all_Data, and save it into a new dataframe: slim_Data

## This is accomplished using the subset function or just square brackets.

slim_Data <- all_Data[, all_Cols]   ## Create a new dataframe slim_Data, populate it with only the columns 
                                    ## that we are interested in.

## We are almost done!  You can do it!  Persistence is the answer!

## There is only one single data frame we care about now!  It is called "slim_Data"!!

#############################################################################
## We only need slim_Data from here on in.  We can clear everything else!  ##
#############################################################################

rm(subject_Test)
rm(subject_Train)
rm(x_Test)
rm(x_Train)
rm(y_Train)
rm(y_Test)

rm(x_All)
rm(y_All)
rm(subject_All)

rm(feature_List)
rm(measurement_Names)
rm(numcol)
rm(i)
rm(activity_Names)

##rm(act_Names)            ## Don't delete this, we still need it for a minute for sorting stuff

rm(index)
rm(numrows)

rm(all_Cols)
rm(both_Cols)
rm(len)
rm(mean_Cols)
rm(n)
rm(onetwo)
rm(std_Cols)

rm(all_Data)


##############################################################################
## Now we need to sort the slim_Data by two factors: subject, and activity  ##
##############################################################################

## Let's bring back act_Names and add it as a new column to slim_Data
## This is easier than trying to use the activity data (string type) as an index.

## I understand this is a violation of tidy data, but I need to use this extra column as an index 
## and then I'll get rid of it later.

## use cbind to slap a new column onto slim_Data

slim_Data <- as.vector(cbind(slim_Data,act_Names))   ## Now slim_Data has a new 69th column we can use as a handy index.

## Now we sort slim_Data.   first sort by subject, second sort by activty code

## slim_Data[order(slim_Data$subject, slim_Data$act_Names),]  ## can be done without plyr

slim_Data <- arrange(slim_Data,subject,act_Names)             ## easlier with plyr







###############################################################################################
## The next step is to consolidate the data even further, from 10,999 rows down to about 180 ##
###############################################################################################

## Those 180 rows will contain the mean of all the values for each column, for each subject, for each activity.
## One row each for every combination of subject and activity.. (1-1, 1-2, 1-3 ..... 30-6)

## First, we create a new data frame, tidy_Data, to hold the result.  It should be 180 rows, by 69 columns.
##                                                                    (we're keeping the index column for now.)


## now copy the column names verbatim from slim_Data to tidy_Data.  They should not change at all

## populate the subject column from 1-30, repeating each row 6 times.

## poupulate the act_Names column from 1-6, repeating after each iteration of 6.

## based on act_Names, populate the activity column with the appropriate strings.. "WALKING", "STANDING", etc... 

## now we loop through slim_Data, extract the mean of the columns we are interested in, and save it to the 
## appropriate location in tidy_Data.  

## the ddply function does all this for us.  

tidy_Data <- ddply(slim_Data, c("subject", "act_Names"), numcolwise(mean))


#############################################################################################################
## We now have the tidy Data set!  Our last step is to save it as a text file, and return the data frame.  ##
#############################################################################################################



write.table(tidy_Data,"tinydata.txt", row.name="FALSE", sep="\t")        ## write a text file named 
             
return (tidy_Data)                                     ## The last thing this funciton does is Return tidy_Data

}
