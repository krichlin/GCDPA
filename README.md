# GCDPA
Getting and Cleaning Data Programming Assignment 

Markdown file for run_analysis.R 

Kenneth Richlin

The script run_analysis.R accepts as input the dataset "Human Activity Recognition Using Smartphones" provided by Samsung.

It can be called as a function run_analysis() with no arguments.  It will return the data frame tiny_Data (see codebook below)

The script begins by opening several files from the dataset and reading them in.  The necessary files include:

activity_labels.txt   - Strings that denote a total of 6 types of activity that the data tracks.
features.txt          - A list of 561 variable names that are tracked for each measurement

In the /test directory, we also need:

test/subject_test.txt - A 1 column table indicating which subject out of 30 corresponds to each row of the test data.
test/X_test.txt       - A 561 column table containing the measurement data for all the test subjects
test/y_test.txt       - A 1 column table indicating which activity corresponds to a given measurement in X_test.txt

in the /train directory, we also need:

train/subject_test.txt - A 1 column table indicating which subject of 30 corresponds to each row of training data.
train/X_train.txt      - A 561 column table containing the measurement data for all training subjects.
train/y_train.txt      - A 1 column table indicating which activity corresponds to a given measurement in X_train.txt

The script reads this data into data frames and then sets about manipulating them into a form we can more easily work with.

The frames x_Train and x_Test are merged into x_All
The frames y_Train and y_Test are merged into y_All
the frames subject_Train and subject_Test are merged into subject_All

Column names in subject_All and y_All are given meaningful names: "subject" and "activity" respectively.

The frames subject_All, y_All and x_All are merged by column together into a new frame all_Data.

The meaningful column names for the measurements are extracted from feature.txt and applied to all_Data.

Meaningful activity names from activity_labels.txt are then applied to the the "activity" column of all_Data.

all_Data still contains a lot of data we do not need.  So then a new data frame slim_Data is created to contain
only the subset of all_Data we are interested in - measurements containing the phrase "-mean(" or "-std("

At this point in the script, we have created a large number of intermediary variables and frames, which we 
no longer need.  So we clean much of this out of the memory.

slim_Data is then sorted by two factors - first subject, then activity.

We are left with an ordered frame of 10,999 rows.  We are now tasked with calculating the mean of every
measurement column remaining, for each of 30 subjects and 6 activities.  Our resulting array, tidy_Data,
will have 180 rows and 68 columns.

The script writes tidy_Data to a file, and also returns it as a function call.



Codebook:

tidy_Data - a data frame of:
68 columns 
first two columns indicate subject and activity
last 66 columns contain average measurement data for each mean or std measurement made.

and 180 rows
each row corresponds to one unique combination of subject and activity.  For instance,
row 1 corresponds to subject 1, activity 1.  row 2 is subject 2, activity 2... and so forth.
these rows cycle through all 30 subjects and 6 activities.  The final (180th) entry
refers to subject 30, activity 6.  
