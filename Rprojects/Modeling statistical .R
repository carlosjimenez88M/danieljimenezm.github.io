# =======================================
# =         Statistical Modeling        =          
# =           Daniel Jiménez            =
# =       Senior Data Scientist         =
# =            Merlin Jobs              =
# =            2019-10-06               =
# =======================================

# libraries ------------------------------
library(tidyverse)
library(tidybayes)
library(moderndive)
theme_set(theme_classic())


# Load Datasets ----------------------------
evals<-read.csv('Desktop/evals.csv')


# Problem ---------------------------------
# Can we explain differences in teaching evaluation score based on various teacher attributes?
# Where 
#   $y$= Average teaching score based on student evaluations
#   $x$= Attributes 

# EDA -------------------------------------

# Three basic steps for EDA
# 1. Looking Data
# 2. Creating visualization
# 3. Computing summary statistics

evals%>%
  glimpse()



evals%>%
  ggplot(aes(score))+
  geom_histogram(binwidth = 0.25)+
  labs(x='scores',title = 'Histrogram Teaching Scores')

evals%>%
  ggplot(aes(age))+
  geom_histogram(binwidth = 5)+
  labs(x='age',title = 'Histrogram Teaching Ages')





evals%>%
  summarize(mean_score=mean(score),median_score=median(score),
            sd_score=sd(score))



evals %>%
  summarize(mean_age = mean(age),
            median_age = median(age),
            sd_age = sd(age))


# Modeling for prediction ------------------

# New Problem
# Can we predict the sale price of houses based on their features?

houses<-read.csv('Desktop/kc_house_data.csv')


# Variables 
# $y$= House sales prices
# $x$= Explanatory


# EDA
houses%>%
  glimpse()


houses%>%
  mutate(log_prices=log10(price))%>%
  ggplot(aes(log_prices))+
  geom_histogram()+
  labs(x='Houses Prices')


ggplot(houses, aes(x = sqft_living)) +
  geom_histogram() +
  labs(x = "Size (sq.feet)", y = "count")

# Add log10_size
house_prices_2 <- houses %>%
  mutate(log10_size = log10(sqft_living))

# Plot the histogram  
ggplot(house_prices_2, aes(x = log10_size)) +
  geom_histogram() +
  labs(x = "log10 size", y = "count")


# EDA of Relations --------------------------

evals%>%
  ggplot(aes(x = age, y = score, color=factor(gender))) +
  geom_point() + 
  labs(x = "age", y = "score", title = "Teaching score over age",color='Gender')



evals%>%
  ggplot(aes(x = age, y = score, color=factor(gender))) +
  geom_jitter() + 
  labs(x = "age", y = "score", title = "Teaching score over age",color='Gender')

# Correlations


evals%>%
  summarize(correlation=cor(score,age))



ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "beauty score", y = "teaching score")



ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_jitter() +
  labs(x = "beauty score", y = "teaching score")


evals %>%
  summarize(correlation = cor(score, bty_avg))



# Apply log10-transformation to outcome variable
house_prices <- houses %>%
  mutate(log10_price = log10(price))
# Boxplot
ggplot(house_prices, aes(x = factor(condition), y = log10_price)) +
  geom_boxplot() +
  labs(x = "house condition", y = "log10 price", 
       title = "log10 house price over condition")


house_prices %>% 
  group_by(condition) %>% 
  summarize(mean = mean(log10_price), sd = sd(log10_price), n = n())

# Predictions for house with three conditions

10^(5.67)



# View the structure of log10_price and waterfront
house_prices %>%
  select(log10_price, waterfront) %>%
  glimpse()

# Plot 
ggplot(house_prices, aes(x = factor(waterfront), y = log10_price)) +
  geom_boxplot() +
  labs(x = "waterfront", y = "log10 price")


house_prices %>%
  mutate(waterfront=factor(waterfront))%>%
  group_by(waterfront) %>%
  summarize(mean_log10_price = mean(log10_price), n = n())


# Prediction of price for houses with view
10^( 5.66)

# Prediction of price for houses without view
10^(6.12)

# Explaining ---------------------------------

evals%>%
  ggplot(aes(age,score,color=factor(gender)))+
  geom_point()+
  geom_smooth(method = 'lm',se=FALSE, col='blue')+
  facet_wrap(~gender)+
  labs(x='Age',y='Scores',title = "Teaching score over age",color='Gender')

# Computing slope and intercept 
model_1<-lm(score~age,data = evals)

model_1%>%
  summary()


get_regression_table(model_1)

get_regression_points(model_1)

# Fit regression model
model_score_2 <- lm(score ~ bty_avg, data = evals)

# Get regression table
get_regression_table(model_score_2)

# Get all fitted/predicted values and residuals
get_regression_points(model_score_2)



# Get all fitted/predicted values and residuals
get_regression_points(model_score_2) %>% 
  mutate(score_hat_2 = 3.88 + 0.067 * bty_avg)



# Explaining teaching score

evals%>%
  ggplot(aes(gender,score,fill=gender))+
  geom_boxplot()+
  guides(fill=FALSE)+
  labs(x='Gender', y='Score',title = 'Comparating Score 
through gender')

evals%>%
  ggplot(aes(score,fill=gender))+
  geom_histogram(binwidth = .25)+
  guides(fill=FALSE)+
  facet_wrap(~gender, scales = 'free')


# New regression model

model_3<-lm(score~gender,data=evals)

#Get regression table

get_regression_table(model_3)

# In the estimate , only computing diferences slope between female and male

# Compute group means based on gender

evals%>%
  group_by(gender)%>%
  summarize(mean_score=mean(score),
            median_score=median(score))



# Computing rank

evals %>%
  group_by(rank)%>%
  summarize(n=n())



# EDA for RANK

evals%>%
  ggplot(aes(rank,score,fill=rank))+
  geom_boxplot()+
  guides(fill=FALSE)+
  labs(x='Ranks',y='Score')

evals%>%
  ggplot(aes(score,fill=rank))+
  geom_histogram(binwidth = 0.5)+
  guides(fill=FALSE)+
  facet_wrap(~rank,scales = 'free')



evals%>%
  group_by(rank)%>%
  summarize(mean_score=mean(score),
            median_score=median(score),
            sd_score=sd(score))


# Fit regression model
model_score_4 <- lm(score ~ rank, data = evals)

# Get regression table
get_regression_table(model_score_4)



# teaching mean
teaching_mean <- 4.28

tenure_track_mean <- 4.28 - 0.130


# tenured mean
tenured_mean <- 4.28 - 0.145



# Prediction and some relevants interpretations

model_3<-lm(score~gender,data = evals)
get_regression_table(model_3)
get_regression_points(model_3)




# Get regression points
model_score_3_points <- get_regression_points(model_3)
model_score_3_points

ggplot(model_score_3_points, aes(x = residual)) +
  geom_histogram() +
  labs(x = "residuals", title = "Residuals from score ~ gender model")


# Multiple regression 


houses%>%
  mutate(log_prices=log10(price),
         log_size=log10(sqft_living))->Houses


Houses%>%
  ggplot(aes(log_prices))+
  geom_histogram()

Houses%>%
  ggplot(aes(log_size))+
  geom_histogram()




model_price_1 <- lm(log_prices ~ log_size + yr_built, 
                    data = Houses)


# Output regression table
get_regression_table(model_price_1)


house_prices_transform <- Houses %>%
  filter(bedrooms<33)


ggplot(house_prices_transform, aes(x = bedrooms, y =log_prices )) +
  geom_point() +
  labs(x = "Number of bedrooms", y = "log10 price") +
  geom_smooth(method = "lm", se = FALSE)



# Fit model
model_price_2 <- lm(log_prices~log_size+bedrooms, 
                    data = house_prices_transform)

# Get regression table
get_regression_table(model_price_2)


model_price_1 <- lm(log_prices ~ log_size + yr_built, 
                    data = house_prices_transform)

get_regression_table(model_price_1)

# Make perdiction
10^(5.38+0.913-0.001*1980)


# Information for general model

get_regression_points(model_price_1)

# Square all residuals and sum them

get_regression_points(model_price_1)%>%
  mutate(sq_residuals=residual^2)%>%
  summarize(sum_sq_residuals=sum(sq_residuals))

# Exercise -----------------------------

#Say you want to predict the price of a house using this model and you know it has:
  
#  1000 square feet of living space, and
#  3 bedrooms

# Make prediction in log10 dollars
2.69 + 0.941 * log10(1000) - 0.033 * 3

# Make prediction dollars
10^(2.69 + 0.941 * log10(1000) - 0.033 * 3)

# Other alternative
house_prices <- house_prices %>%
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
  )



# Group mean & sd of log10_price and counts
house_prices %>% 
  group_by(condition) %>% 
  summarize(mean = mean(log10_price), sd = sd(log10_price), n = n())



# Fit regression model using formula of form: y ~ x1 + x2
house_prices_transform%>%
  mutate(condition=factor(condition))->house_prices_transform
model_price_3 <- lm(log_prices ~ log_size + condition,
                    data = house_prices_transform)

# Output regression table
get_regression_table(model_price_3)

#Predicting house price using size & condition-----------

#First house: \hat{y} = 2.88 + 0.032 + 0.837 \cdot 2.90 = 5.34
#Second house: \hat{y} = 2.88 + 0.044 + 0.837 \cdot 3.60 = 5.94


model_price_3 <- lm(log_prices ~ log_size + condition,
                    data = house_prices_transform)
get_regression_table(model_price_3)


# Create data frame of "new" houses
new_houses <- data_frame(
  log_size = c(2.9, 3.6),
  condition = factor(c(3, 4))
)
new_houses


# Make predictions on new data

get_regression_points(model_price_3, newdata = new_houses)

get_regression_points(model_price_3, newdata = new_houses)%>%
  mutate(prediction_price=10^(log_prices_hat))



# Get regression table
get_regression_table(model_price_3)

# Prediction for House A
10^(2.96 + 0.825 * 2.9 + 0.322)

# Prediction for House B
10^(2.96 + 0.825 * 3.1)


# Model selection and assessment -------------

get_regression_points(model_price_1)

get_regression_points(model_price_1) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(sum_sq_residuals = sum(sq_residuals))


get_regression_points(model_price_3) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(sum_sq_residuals = sum(sq_residuals))


# The better model is model price 1

# Assessing model fit with R-squared

# R Squared 
# R^2=1-\fracc{var(residuals)}{var(y)}
# R^2: he proportion of the total variation in the outcome variable yy that the model explains.



get_regression_points(model_price_1) %>% # The better model
  summarize(r_squared = 1 - var(residual) / var(log_prices))


get_regression_points(model_price_3) %>%
  summarize(r_squared = 1 - var(residual) / var(log_prices))




# Assessing predictions with RMSE ---------------

# Mean squared error: use mean() instead of sum():
get_regression_points(model_price_1) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(mse = mean(sq_residuals))


# Root mean squared error:
get_regression_points(model_price_1) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(mse = mean(sq_residuals)) %>%
  mutate(rmse = sqrt(mse))


# RMSE of predictions on new houses

new_houses <- data_frame(
  log_size = c(2.9, 3.6),
  condition = factor(c(3, 4))
)

get_regression_points(model_price_3, newdata = new_houses)


get_regression_points(model_price_3, newdata = new_houses) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(mse = mean(sq_residuals)) %>%
  mutate(rmse = sqrt(mse))




get_regression_points(model_price_2) %>%
  mutate(sq_residuals = residual^2) %>%
  summarize(mse = mean(sq_residuals)) %>% 
  mutate(rmse = sqrt(mse))



# Validation set prediction framework ---------


house_prices_shuffled <- house_prices %>% 
  sample_frac(size = 1, replace = FALSE)


train <- house_prices_shuffled %>%
  slice(1:10000)
test <- house_prices_shuffled %>%
  slice(10001:21613)



# Set random number generator seed value for reproducibility
set.seed(76)

# Randomly reorder the rows
house_prices_shuffled <- house_prices %>% 
  sample_frac(size = 1, replace = FALSE)

# Train/test split
train <- house_prices_shuffled %>%
  slice(1:10000)
test <- house_prices_shuffled %>%
  slice(10001:21613)

# Fit model to training set
train_model_2 <- lm(log10_price ~ log10_size + bedrooms, data = train)
