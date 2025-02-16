
# Bank Marketing Data Analysis & Modeling

## 1.Introduction:

# This project applies machine learning techniques that go beyond standard linear regression. I had the opportunity to use a publicly available dataset to solve the problem of my choice. I sifted through the datasets available on Kaggle and chose a finance/bank related dataset. I work at a bank so I was geared toward selecting a topic that's relevant to the banking business.
# 
# The goal of the project is to answer the following question:
# What kind of behaviors do potential customers exhibit that result in them more likely to subscribe to a term deposit? 
# 
# The business problem is to devise a target marketing strategy for the bank based on the behavioral data collected.
# The dataset is included in one of the submission files and can be downloaded from Kaggle (https://www.kaggle.com/henriqueyamahata/bank-marketing).
# 
# The Dataset: 
# It contains 41,188 customer data on direct marketing campaigns (phone calls) of a Portuguese banking institution. 
# 
# It has the following variables:
# Client: age, job, marital, education, default status, housing, and loan
# Campaign: last contact type, last contact month of year, last contact day of the week, and last contact duration
# Others: number of contacts performed in current campaign, number of days that passed by after the client was last contacted, number of contacts performed before this campaign, outcome of previous campaign, and whether a client has subscribed a term deposit
# 
# Key Steps Performed:
# I first used Data Classification to examine the set related with direct marketing campaigns of a Portuguese banking institution. The objective of the classification is to predict if the client will subscribe to a Term Deposit. Data Classification is the use of machine learning techniques to organize datasets into related sub-populations, not previous specified in the dataset. This can uncover hidden characteristics within data, and identify hidden categories that new data belongs within. The rest of the key steps that were performed used the data science techniques of Exploratory Data Analysis, Data Classification basis Random Forest and K-Nearest Neighbor.



  
  ## 2.Data Analysis:
  
  
  ### 2.1.Exploratory Analysis
  

rm(list = ls())
options(warn=-1)

if(!require(readr)) install.packages("readr", repos = "")
if(!require(tidyverse)) install.packages("tidyverse", repos = "")
if(!require(GGally)) install.packages("GGally", repos = "")
if(!require(glmnet)) install.packages("glmnet", repos = "")
if(!require(Matrix)) install.packages("Matrix", repos = "")
if(!require(DataExplorer)) install.packages("DataExplorer", repos = "")
if(!require(corrplot)) install.packages("corrplot", repos = "")
if(!require(caret)) install.packages("caret", repos = "")
if(!require(randomForest)) install.packages("randomForest", repos = "")
if(!require(class)) install.packages("class", repos = "")
if(!require(gmodels)) install.packages("gmodels", repos = "")
if(!require(dplyr)) install.packages("dplyr", repos = "")
if(!require(psych)) install.packages("psych", repos = "")


library(readr)
library(tidyverse)
library(GGally)
library(glmnet)
library(Matrix)
library(ggplot2)
library(DataExplorer)
library(corrplot)
library(caret)
library(randomForest)
library(class)
library(gmodels)
library(dplyr)
library(psych)


set.seed(1)


#Loading the dataset:

#setwd("C:/Users/1012233/Downloads/20191103 - R Studio Kaggle project")
#data.df <- read.csv("bank-additional-full.csv", header=TRUE, sep=";")

data.df <- read.csv("https://raw.github.com/amymkalna/Kaggle-Bank-Marketing-Data/master/bank-additional-full.csv", header=TRUE, sep=";")


  
  
  ##Viewing the column names of the dataset:##

names(data.df)

  ##Column details of the dataset:##
str(data.df)

  ##Summary analysis of the dataset:##

summary(data.df)



  ### 2.2.Data Preparation
  
  ##We check if there are any missing values that exists:##

sum(is.na(data.df))
#There are no missing values in our dataset.

  
#In the above exploratory analysis, we observed that there are many variables with class=int; hence, we convert them into numeric class

##Converting quantitative values to numeric class:##

data.df$age <- as.numeric(data.df$age)
data.df$duration <- as.numeric(data.df$duration)
data.df$campaign <- as.numeric(data.df$campaign)
data.df$pdays <- as.numeric(data.df$pdays)
data.df$previous <- as.numeric(data.df$previous)



  
  
  ##Ordering the levels of month:##

data.df$month<- factor(data.df$month, ordered = TRUE, levels = c("mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"))




  
#Since are target variable is a categorical variables with 2 possible values: yes, no; we transform it into a numerical denotation: 1,0 respectively.

##Transforming the target variable as Yes=1 and No=0:##

table(data.df$y)



data.df <- data.df %>%
  mutate(y = ifelse(y=="yes", 1, 0))

data.df$y <- as.factor(data.df$y)
table(data.df$y)



  
  ### 2.3.Descriptive Analysis
  
  ##Let us look at the histogram of the input variables:##
  

plot_histogram(data.df[,-21],ggtheme = theme_gray(base_size = 10, base_family = "serif"))



  

mytable <- table(data.df$marital, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("marital", "y", "perc")
ggplot(data = tab, aes(x = marital, y = perc, fill = y)) + 
  geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) + 
  xlab("Marital")+ylab("Percent")


##With respect to Marital Status there is not an observed large difference in the proportion of people subscribed to term deposits and people without term deposits.##
  
  

mytable <- table(data.df$education, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("education", "y", "perc")
ggplot(data = tab, aes(x = education, y = perc, fill = y)) + 
  geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
  theme(axis.text.x=element_text(angle=90,hjust=1)) +
  xlab("Education")+ylab("Percent")

##We can see that customers who sign up for bank deposits, proportionally, have achieved a higher level of education, than those who didn't sign up.##



mytable <- table(data.df$month, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("month", "y", "perc")
ggplot(data = tab, aes(x = month, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Month")+ylab("Percent")

##The month of May is when the highest number of calls were placed for marketing deposit. And the following months of April, September, and October is the time when a higher proportion of people subscribed for term deposits.##




mytable <- table(data.df$job, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("job", "y", "perc")
ggplot(data = tab, aes(x = job, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
theme(axis.text.x=element_text(angle=90,hjust=1)) +
xlab("Job")+ylab("Percent")

##We see there are higher proportions for customers signing up for the term deposits who have the jobs of admin, retired, and students.##




mytable <- table(data.df$default, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("default", "y", "perc")
ggplot(data = tab, aes(x = default, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Default")+ylab("Percent")

##The data shows that people who aren't in default are a higher proportion of people who have subscribed for bank deposits.##
  
  
  
  

mytable <- table(data.df$housing, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("housing", "y", "perc")
ggplot(data = tab, aes(x = housing, y = perc, fill = y)) + 
  geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
  xlab("Housing")+ylab("Percent")

##We see that a higher proportion of people who have subscribed for bank deposit are home owners versus ones that don't own their own houses.##





mytable <- table(data.df$loan, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("loan", "y", "perc")
ggplot(data = tab, aes(x = loan, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Loan")+ylab("Percent")

##We see the proportion of people who have subscribed and not subscribed to a term deposit is the same for categories of the Loan.##





mytable <- table(data.df$contact, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("contact", "y", "perc")
ggplot(data = tab, aes(x = contact, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Contact")+ylab("Percent")

##Customers who have cell phones, and therefore a more direct way of communicating, signed up for term deposits more than those who only had a landline telephone.##





mytable <- table(data.df$day_of_week, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("day_of_week", "y", "perc")
ggplot(data = tab, aes(x = day_of_week, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Day_of_week")+ylab("Percent")

##Campaigns that were performed midweek, on Tuesdays, Wednesdays, and Thursdays had a slightly higher proportion of people who subscribed for bank deposit..##



mytable <- table(data.df$poutcome, data.df$y)
tab <- as.data.frame(prop.table(mytable, 2))
colnames(tab) <-  c("poutcome", "y", "perc")
ggplot(data = tab, aes(x = poutcome, y = perc, fill = y)) + 
geom_bar(stat = 'identity', position = 'dodge', alpha = 2/3) +
xlab("Outcome of previous marketing campaign")+ylab("Percent")

##Potential customers who successfully connected and responded in previous campaigns had a higher proportion of signing up for the term deposit.##






ggplot(data.df, aes(factor(y), duration)) + geom_boxplot(aes(fill = factor(y)))

##The longer the phone conversation the greater the conversion rate is for the potential customer to sign up for the term deposit. There are higher median and quartile ranges.##



ggplot(data.df, aes(factor(y), age)) + geom_boxplot(aes(fill = factor(y)))

##The age range for successful conversion has a slightly lower median, but higher quartile ranges.##












df_cor <- select_if(data.df, is.numeric) %>% cor()
corrplot(df_cor, method = "number")

##We see our target variable has a high positive correlation with duration and if the customer was involved and connected in a previous campaign, while there's negative correlation with Nr.employed (number of employees), pdays (number of days from last contact), Euribor3m (Euribor 3 month rate) and emp.var.rate (employee variation rate).##
  
  ##*
  
  
  
  
  ## 3.Data Modeling and Results:
  
  
  ### 3.1.Data Preparation
  
  
  ##Missing values for duration were filtered out (last contact duration, in seconds (numeric)) because if duration=0 then y="no" (no call was made). Thus, it doesn't make sense to have 0 second duration. I also filtered out education illiterate, and default yes because they only have 1 observation each. We can't predict these situations if they happen to be in the test data but not the train data.##
  

data.df <- data.df %>%
  filter(duration != 0, education != "illiterate", default != "yes") %>%
  mutate(y = ifelse(y==1, 1, 0))


##Split the data into training and test datasets:##
  

set.seed(123)
trainIndex <- createDataPartition(data.df$y,
                                  p = 0.8, # training contains 80% of data
                                  list = FALSE)
dfTrain <- data.df[ trainIndex,]
dfTest  <- data.df[-trainIndex,]



dim(dfTrain)



dim(dfTest)

#The code and output above show that the trainData dataset has 8929 rows and 17 columns and the testData dataset gas 2233 rows and 17 columns. The number of columns remains the same because the dataset was split vertically.


  
  ### 3.2.Data Modeling using Random Forest:
  
# First the data set was divided into training and testing data with 80%-20% split respectively. A seed value was set using set.seed() function to make sure that the randomly split data could be regenerated. A random forest model was built using training data using randomforest package. We use 10 predictors for each split and grow 200 trees fully without pruning. A subset of predictors is randomly chosen without replacement at each split which helps in reducing the variance of the model overall. This is a prime advantage of random forest as compared to traditional decision trees.
# 
# In the below summary we can see that this model has an Out-Of-Bag error rate of 8.7%. The model also outputs a confusion matrix. We can see that random forest is doing a fairly good job in predicting the response variable i.e. deposit(Yes/No) field.



set.seed(123)

# random forest
model_rf <- randomForest(as.factor(y)~.,
                         data = dfTrain,
                         ntree = 200,
                         mtry=10,
                         importance = TRUE)

print(model_rf)



pred_rf_prob <- predict(model_rf,
                        newdata = dfTest)



head(pred_rf_prob)


##Model evaluation:##


# put "pred_rf_prob" in a data frame
RF_outcome_test <- data.frame(dfTest$y)

# merge "model_rf" and "RF_outcome_test" 
RF_comparison_df <- data.frame(pred_rf_prob, RF_outcome_test)

# specify column names for "RF_comparison_df"
names(RF_comparison_df) <- c("RF_Predicted_y", "RF_Observed_y")

RF_comparison_df$RF_Predicted_y <- as.factor(RF_comparison_df$RF_Predicted_y)
RF_comparison_df$RF_Observed_y <- as.factor(RF_comparison_df$RF_Observed_y)

# inspect "RF_comparison_df" 
head(RF_comparison_df)


str(RF_comparison_df)


confusionMatrix(RF_comparison_df$RF_Observed_y,RF_comparison_df$RF_Predicted_y)



# The RF test data consisted of 8232 observations. Out of which 7034 cases have been accurately predicted (TN->True Negatives) as negative class (0) which constitutes 85%. Also, 510 out of 8232 observations were accurately predicted (TP-> True Positives) as positive class (1) which constitutes 6%. Thus a total of 510 out of 8232 predictions where TP i.e, True Positive in nature.
# 
# There were 420 cases of False Positives (FP) meaning 544 cases out of 8232 were actually negative but got predicted as positive.
# 
# There were 268 cases of False Negatives (FN) meaning 199 cases our of 8232 were actually positive in nature but got predicted as negative.
# 
# Accuracy of the model is the correctly classified positive and negative cases divided by all ther cases.The total accuracy of the model is 91.64%, which means the model prediction is very accurate.
# 



##Viewing the variable importance plot:##

varImpPlot(model_rf)

##By setting the importance argument on, we obtained the variable importance plot as above using varImpPlot() function and we can see that duration is highly significant in our data set.## 
  
  
##We plot a graph for the error rate (False Positive Rate, False Negative Rate and Out-Of-Bag Error) with the increasing number of trees.

plot(model_rf)
legend("right", legend=c("OOB Error", "FPR", "FNR"),
       col=c("black", "red", "green"), lty=1:3, cex=0.8)



##In the above plot, we can see the change of error with increasing number of trees. The False Negative Rate is higher compared to other error rate and False Positive Rate is lowest. The error rate starts dropping for at ntree~ 20. This says that our model is predicting 'Yes' cases more accurately than 'No' cases which can also be confirmed by the confusion matrix above.


  
  
  ## 3.2.Data Modeling using KNN
  ##We will make a copy of our data set so that we can prepare it for our k-NN classification. 


data_knn <- data.df

str(data_knn)



# Because k-NN algorithm involves determining distances between datapoints, we must use numeric variables only. This is applicable only to independent variables. The target variable for k-NN classification should remain a factor variable.
# First, we scale the data just in case our features are on different metrics. For example, if we had "duration" as a variable, it would be on a much larger scale than "age", which could be problematic given the k-NN relies on distances. Note that we are using the 'scale' function here, which means we are scaling to a z-score metric.
# 
# We see that the variables "age", "duration", "campaign", "pdays", "previous", "emp.var.rate", "cons.price.idx", "cons.conf.idx", "euribor3m"  and "nr.employed" are interger variables, which means they can be scaled.



data_knn[, c("age", "duration", "campaign", "pdays", "previous", "emp.var.rate", "cons.price.idx", "cons.conf.idx", "euribor3m","nr.employed")] <- scale(data_knn[, c("age", "duration", "campaign", "pdays", "previous", "emp.var.rate", "cons.price.idx", "cons.conf.idx", "euribor3m","nr.employed")])

head(data_knn)





str(data_knn)


##We can see that the variables "job", "marital", "education", "default", "housing", "loan", "contact", "month", "day_of_week" and "poutcome" are factor variables that have two or more levels.##
  
  
  ## Then dummy code variables that have two levels, but are not numeric. ##

data_knn$contact <- dummy.code(data_knn$contact)



  ##Next we dummy code variables that have three or more levels.##

job <- as.data.frame(dummy.code(data_knn$job))
marital <- as.data.frame(dummy.code(data_knn$marital))
education <- as.data.frame(dummy.code(data_knn$education))
default <- as.data.frame(dummy.code(data_knn$default))
housing <- as.data.frame(dummy.code(data_knn$housing))
loan <- as.data.frame(dummy.code(data_knn$loan))
month <- as.data.frame(dummy.code(data_knn$month))
day_of_week <- as.data.frame(dummy.code(data_knn$day_of_week))
poutcome <- as.data.frame(dummy.code(data_knn$poutcome))



  ##Rename "unknown" columns, so we don't have duplicate columns later).##

job <- rename(job, unknown_job = unknown)
marital <- rename(marital, unknown_marital = unknown)
education <- rename(education , unknown_education  = unknown)
default <- rename(default , unknown_default  = unknown)
housing <- rename(housing , unknown_housing  = unknown)
loan <- rename(loan , unknown_loan  = unknown)

default <- rename(default , yes_default  = yes)
default <- rename(default , no_default  = no)

housing <- rename(housing , yes_housing  = yes)
housing <- rename(housing , no_housing  = no)

loan <- rename(loan , yes_loan  = yes)
loan <- rename(loan , no_loan  = no)



  ##Combine new dummy variables with original data set.##

data_knn <- cbind(data_knn, job, marital, education, default, housing, loan, month, day_of_week,poutcome)




str(data_knn)



##Remove original variables that had to be dummy coded.##

data_knn <- data_knn %>% select(-one_of(c("job", "marital", "education", "default", "housing", "loan", "month", "day_of_week", "poutcome")))

head(data_knn)

#We are now ready for k-NN classification. We split the data into training and test sets. We partition 80% of the data into the training set and the remaining 20% into the test set.

##Splitting the dataset into Test and Train:##

set.seed(1234) # set the seed to make the partition reproducible

# 80% of the sample size
sample_size <- floor(0.8 * nrow(data_knn))


train_index <- sample(seq_len(nrow(data_knn)), size = sample_size)

# put outcome in its own object
knn_outcome <- data_knn %>% select(y)

# remove original variable from the data set
data_knn <- data_knn %>% select(-y)



# creating test and training sets that contain all of the predictors
knn_data_train <- data_knn[train_index, ]
knn_data_test <- data_knn[-train_index, ]

# Split outcome variable into training and test sets using the same partition as above.
knn_outcome_train <- knn_outcome[train_index, ]
knn_outcome_test <- knn_outcome[-train_index, ]




##Using 'class' package, we run k-NN classification on our data. We have to decide on the number of neighbors (k).This is an iterative exercise as we need to keep changing the value of k to dtermine the optimum performance. In our case, we started with k=10 till k=20, and finally got an optimum performance at k=17.


model_knn <- knn(train = knn_data_train, test = knn_data_test, cl = knn_outcome_train, k=17)


##Model evaluation:##


# put "knn_outcome_test" in a data frame
knn_outcome_test <- data.frame(knn_outcome_test)

# merge "model_knn" and "knn_outcome_test" 
knn_comparison_df <- data.frame(model_knn, knn_outcome_test)

# specify column names for "knn_comparison_df"
names(knn_comparison_df) <- c("KNN_Predicted_y", "KNN_Observed_y")

knn_comparison_df$KNN_Predicted_y <- as.factor(knn_comparison_df$KNN_Predicted_y)
knn_comparison_df$KNN_Observed_y <- as.factor(knn_comparison_df$KNN_Observed_y)

# inspect "knn_comparison_df" 
head(knn_comparison_df)



# Next, we compare our predicted values of deposit to our actual values. The confusion matrix gives an indication of how well our model predicted the actual values.
# The confusion matrix output also shows overall model statistics and statistics by class


confusionMatrix(knn_comparison_df$KNN_Observed_y,knn_comparison_df$KNN_Predicted_y)



# The K-nn test data consisted of 8238 observations. Out of which 7128 cases have been accurately predicted (TN->True Negatives) as negative class (0) which constitutes 87%. Also, 367 out of 8238 observations were accurately predicted (TP-> True Positives) as positive class (1) which constitutes 4%. Thus a total of 367 out of 8238 predictions where TP i.e, True Positive in nature.
# 
# There were 544 cases of False Positives (FP) meaning 544 cases out of 8238 were actually negative but got predicted as positive.
# 
# There were 199 cases of False Negatives (FN) meaning 199 cases were actually positive in nature but got predicted as negative.
# 
# Accuracy of the model is the correctly classified positive and negative cases divided by all ther cases.The total accuracy of the model is 91.13%, which means the model prediction is very accurate.
# 
#
  
  
  
  
  
  ## 4.Conclusion:
  
  ### Model Comparison:
#   Both the algorithms namely Random Forest and K Nearest Neignbor are generaing high accuracy when trained with the bank marketing dataset. 
# 
# The parameter comparision for both the model is:
#   
#   Parameter              Random Forest        K-nn Model
# -------------------- |----------------------|----------------|
#   Accuracy        |         91.64%       |     91.13%     |
#   -------------------- |----------------------|----------------|
#   Sensitivity     |         94.37%       |     93.03%     |
#   -------------------- |----------------------|----------------|
#   Specificity     |         65.55%       |     65.68%     |
#   -------------------- |----------------------|----------------|
#   Pos Pred Value  |         96.33%       |     97.31%     |
#   -------------------- |----------------------|----------------|
#   Neg Pred Value  |         54.84%       |     41.38%     |
#   -------------------- |----------------------|----------------|
#   
#   
#   - The accuracy of both the algorithms is very similar, and random forest model has a slightly higher accuracy compared to K-nn model.
# - The sensitivity and specificity of both the algorithms is also very close, and random forest model has a slightly higher sensitivity compared to K-nn model.
# - The Positive Pred Value of random forest model is a little lower as compared to K-nn model.
# - The Negative Pred Value of random forest model is nearly 10% higher as compared to K-nn model.
# 
# At an overall level, the performance of both the model is similar, however Random Forest model has a better prediction performance for Negative classes and hence, we can go forward with selecting Random Forest as a better model for our objective.
# 

### Analysis Summary:
# The key insights derived from the overall analysis are:
#   - With respect to Marital Status, there is not an observed large difference in the proportion of people subscribed to term deposits and people without term deposits.
# - Customers who sign up for bank deposits, proportionally, have achieved a higher level of education, than those who didn't sign up.
# - The months of April, September, and October is the time when a higher proportion of people subscribed for term deposits.
# - There are higher proportions for customers signing up for the term deposits who have the jobs of admin, retired, and students.
# - People who aren't in default are a higher proportion of people who have subscribed for bank deposits.
# - Higher proportion of people who have subscribed for bank deposit are home owners versus ones that don't own their own houses.
# - The proportion of people who have subscribed and not subscribed to a term deposit is the same for categories of the Loan.
# - Customers who have cell phones, and therefore a more direct way of communicating, signed up for term deposits more than those who only had a landline telephone.
# - Campaigns that were performed midweek, on Tuesdays, Wednesdays, and Thursdays had a slightly higher proportion of people who subscribed for bank deposit.
# - Potential customers who successfully connected and responded in previous campaigns had a higher proportion of signing up for the term deposit.
# - The longer the phone conversation the greater the conversion rate is for the potential customer to sign up for the term deposit. There are higher median and quartile ranges.
# - The age range for successful conversion has a slightly lower median, but higher quartile ranges.
# - Subscribing to term deposit has a high positive correlation with duration and if the customer was involved and connected in a previous campaign, while there's negative correlation with Nr.employed (number of employees), pdays (number of days from last contact), Euribor3m (Euribor 3 month rate) and emp.var.rate (employee variation rate).
# 
# 
# Using the above insights, the bank should devise a target marketing strategy that is customized towards potential customers with higher education, work in admin related job or are either students or retired, have an existing account with the bank, have registered using a mobile phone number, and have responded positively to campaigns in the past. Also, in order to improve the probability of success, the campaigns should be launched in months such as April, September and October. It is also advised that the bank representative should spend maximum time on the call with the potential customer which increases the probability of the customer to subscribe term deposit.
# 
# 
# 
# ### Future Work:
# Data analytics is usually used to analyze and work with big data such as the one we provided in the project here. It eases the cross-examination of the data and the methods of finding relationships within the data, so it becomes easier. There is a lot of things that we can do in future upon the existing model such as determining the right day of the week and time for each of the target audience or build custom models for individual clusters to further improve the prediction rate and reduce the error rate.

##*
  