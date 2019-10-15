# ==============================================
# =   Representation model problem with broom  =
# =                Daniel Jiménez              =
# =           Senior Data Scientist            =
# =                 Merlin Jobs                =
# =                 2019-10-14                 =
# ==============================================



# libraries ------------------------------------
library(tidyverse)
library(broom)
library(corrr)
library(datasets)
library(GGally)
theme_set(theme_light())




# Load Data ------------------------------------
data("iris")


# EDA-------------------------------------------

iris%>%
  summary()



iris%>%
  ggpairs()


# Now, with corrr compute correlation by differents variables


iris%>%
  dplyr::select(-Species)%>%
  correlate()%>%
  rearrange()



iris%>%
  dplyr::select(-Species)%>%
  correlate()%>%
  rearrange()%>%
  shave()%>%
  fashion()




iris%>%
  dplyr::select(-Species)%>%
  correlate()%>%
  rearrange()%>%
  shave()%>%
  rplot()



iris%>%
  dplyr::select(-Species)%>%
  correlate()%>%
  network_plot()



# find distribution -------------------------


iris%>%
  ggplot(aes(Sepal.Length))+
  geom_histogram()


iris$Sepal.Length%>%
  summary()

fitdistr(iris$Sepal.Length,'normal')

descdist(iris$Sepal.Length, discrete = FALSE)

fit.norm <- fitdist(iris$Sepal.Length, "norm")
fit.lognorm <-fitdist(iris$Sepal.Length,"lnorm")
plot(fit.norm)
plot(fit.lognorm)


# Sepal.Width


descdist(iris$Sepal.Width, discrete = FALSE)
w_fit<-fitdist(iris$Sepal.Length,'weibull')
n_fit<-fitdist(iris$Sepal.Length,'norm')
ln_fit<-fitdist(iris$Sepal.Length,'lnorm')
plot(w_fit)
plot(n_fit)
plot(ln_fit) # Log normal 



w_fit$aic
n_fit$aic
ln_fit$aic



# Create function for this

ln_fit<-MASS::fitdistr(
  iris$Sepal.Length,
  dlnorm,
  start = list(meanlog=0,sdlog=0.01))


tidy(ln_fit)
glance(ln_fit)


# Create object


iris_model<-lm(Sepal.Length ~ Sepal.Width +Petal.Length+Petal.Width, data = iris)
str(iris_model)
tidy(iris_model)
glance(iris_model)


# Fits -----------------------------------


fits<-list(
  fit1 <-lm(Sepal.Length ~ Sepal.Width, data = iris),
  fit2 <-lm(Sepal.Length ~ Sepal.Width +Petal.Length, data = iris),
  fit3 <-lm(Sepal.Length ~ Sepal.Width +Petal.Length + Petal.Width , data = iris)
)


# Comparing models by goodness of fit neasures

gof<-map_df(fits,glance,.id ='model')%>%
  arrange(AIC)


gof
library(broom)

# Inspect redisuals from multiple lineal regression
iris2<-iris
colnames(iris2)=c('Sepal_Length','Sepal_Width','Petal_Length','Petal_Width','Species')
fit3 <-lm(Sepal_Length ~ Sepal_Width +Petal_Length + Petal_Width , data = iris2)

au<-broom::augment(fit3)

au%>%
  gather(x,val,-contains("."))%>%
  ggplot(aes(val,.resid))+
  geom_point()+
  facet_wrap(~x,scales = 'free')+
  labs(x='Predictior Value', y='Residual')



iris2%>%
  ggplot(aes(Petal_Width,Sepal_Length))+
  geom_point()
# botstrapping


library(rsample)


boots<-bootstraps(iris2, times = 100)  
boots
attach(iris2)
fit_nls_bootstrap<- function(split){
  nls(
    Petal_Width ~ k / Sepal_Length + b,
    analysis(split),
    start = list(k=1,b=0)
  )
}  


boots_fits<-boots%>%
  mutate(fit=map(splits,fit_nls_bootstrap),
         coef_info=map(fit,tidy))



boot_coef<-boots_fits%>%
  unnest(coef_info)

boot_coef%>%
  ggplot(aes(estimate))+
  geom_histogram()+
  facet_wrap(~ term, scales = 'free')+
  labs(x='Value',
       y='Count',
       title = 'Sampling distribution of K and B')



boot_aug<-boots_fits%>%
  mutate(augmented=map(fit,augment))%>%
  unnest(augmented)


boot_aug%>%
  ggplot(aes(Sepal_Length,Petal_Width))+
  geom_point()+
  geom_line(aes(y=.fitted, group=id),alpha=0.2)






