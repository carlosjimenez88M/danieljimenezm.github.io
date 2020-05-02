# =======================================
# =           Deep learning             =        
# =           Daniel Jiménez            =
# =       Senior Data Scientist         =
# =            Merlin Jobs              =
# =            2019-10-28               =
# =======================================


# Libraries------------------------------
library(caret)
library(keras)
library(tidyverse)
theme_set(theme_classic())


# Load Dataset --------------------------
data<-readr::read_csv('https://raw.githubusercontent.com/juanklopper/MachineLearningDataSets/master/CTG.csv')



# Explore and Transform 

data%>%
  glimpse()


data$NSP[data$NSP==1]<-0
data$NSP[data$NSP==2]<-1
data$NSP[data$NSP==3]<-2
#data$NSP<-as.factor(data$NSP)


# Is necessary create data how matrix

data<-as.matrix(data)

# Remove variables names

dimnames(data)<-NULL

# Create split

set.seed(123)

indx <- sample(2,
                nrow(data),
                replace = TRUE,
                prob = c(0.7, 0.3))


x_train <- data[indx == 1, 1:21]
x_test <- data[indx == 2, 1:21]
y_test_actual <- data[indx == 2, 22]

# Tranform sets can be  one - hot -encoded to categorical

y_train <-to_categorical(data[indx == 1, 22])
y_test <- to_categorical(data[indx == 2, 22])


# Normalize data

mean_train <- apply(x_train,
                    2,
                    mean)
std_train <- apply(x_train,
                   2,
                   sd)
x_train <- scale(x_train,
                 center = mean_train,
                 scale = std_train)
x_test <- scale(x_test,
                center = mean_train,
                scale = std_train)



# Create model


model<-keras_model_sequential()
model %>%
  layer_dense(units = 22,
              kernel_regularizer = regularizer_l2(0.001),
              activation = 'relu',
              input_shape=c(21))%>%
  layer_dropout(rate = 0.2)%>%
  layer_dense(units = 12,
              kernel_regularizer = regularizer_l2(0.001),
              activation = "relu") %>% 
  layer_dense(units = 3,
              activation = "softmax")

summary(model)


## Compiling the model ----------------------------------

model%>%
  compile(loss='categorical_crossentropy',
          optimizer='adam',
          metrics = c('accuracy'))



## Fitting Data ----------------------------------------

history<-model%>%
  fit(x_train,
      y_train,
      epoch=40,
      batch_size=64,
      validation_split = 0.2)

plot(history) 




## Model Evaluation 

model%>%
  evaluate(x_test,
           y_test)


# Confution Matrix

pred<-model%>%
  predict_classes(x_test)
  
table(Predict=pred,
      Actual=y_test_actual)
  
  
prob <- model %>% 
  predict_proba(x_test)
cbind(prob,
      pred,
      y_test_actual)
  





