# =======================================
# = Regresión Multivariable y Logística =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =            Merlin Jobs              =
# =            2019-08-06               =
# =======================================


# Librerias -----------------------------------------

rm(list = ls()) # Limpiar consola
library(tidyverse); # Manipulación de datos
library(corrr) # Correlaciones 
library(corrplot) # Gráficos de correlación 
library(statisticalModeling) # MOdelos estadísticos
library(broom)
#library(caTools)
#library(ROCR)
#library(caret)
#library(fitdistrplus)
#library(normtest) ###REALIZA 5 PRUEBAS DE NORMALIDAD###
#library(nortest) ###REALIZA 10 PRUEBAS DE NORMALIDAD###
#library(moments)
#library(fda) 

# Cargar Base de datos

Pokemon<-read.csv("Documents/R/Bases de Datos/Pokemon.csv")%>%
  dplyr::select(-X.)



# Objetivo ---------------------------------------
# Regresión Multiple
# 1. Se desea entender cuales son las variables que determinan el poder de un pokemon
# 2. Se desea saber la proyección de las mismas
# 3. Antesala a un clasificador a través de una regresión logístivca


# Observación de las variables



Pokemon%>%
  ggplot(aes(Defense,Total, color=factor(Legendary)))+
  geom_point()+
  labs(color="")+
  theme(legend.position = "bottom")


# Correlación

cor(Pokemon[,c(4,7)])


# La correlación es buena

Pokemon%>%
  ggplot(aes(x=factor(Legendary), y=Total))+
  geom_boxplot()+
  labs(x="Legendary")+ 
  coord_flip()


# Agregandole ua nueva variable al modelo 

Modelo_1<-lm(Total~ HP+ Defense, data = Pokemon)

Modelo_1%>%
  summary() # EL modelo es bastante bueno, pero podría mejroar

Modelo_2<-lm(Total~ HP+ Defense+ factor(Legendary), data = Pokemon)

Modelo_2%>%
  summary()

# Un p-valor de este tipo indica que se puede rechazar la hipotesis nula 
# O sea que el P-valor sea bajo quiere decir que el predictor 
# tiene una addicón significativa al modelo
# (Cambios en la variable predictor tienen efectos en la respuestas)


# Comprobando la mejor variable de predicción

Pokemon_num<-Pokemon%>%
  dplyr::select(c(4:9))
Pokemon_num$Legendary<-as.factor(Pokemon_num$Legendary)

Modelo_2<-lm(Total~.,data = Pokemon_num)
Modelo_2%>%
  summary() # EL modelo es perfecto 

step(object = Modelo_2, direction = 'both',trace = 1)

# El modelo seleccionado es 


Modelo_seleccionado<-lm(formula = Total ~ HP + Attack + Defense + Sp..Atk + Sp..Def, 
                        data = Pokemon_num)


confint(Modelo_seleccionado)

Pokemon_num%>%
  ggplot(aes(Total,Modelo_seleccionado$residuals))+
  geom_point(color="grey")+
  geom_smooth(color="red")+
  geom_hline(yintercept = 0)+
  theme_classic()


qqnorm(Modelo_seleccionado$residuals)
qqline(Modelo_seleccionado$residuals)

shapiro.test(Modelo_seleccionado$residuals) # La distroibución no es normal 
ad.test(Modelo_seleccionado$residuals)
plotdist(Modelo_seleccionado$residuals)

library(BSDA)


SIGN.test(x,md=0.9,alternative = "two.sided",conf.level = 0.95)
SIGN.test(x,md=0.9,alternative = "greater",conf.level = 0.95)


# Visualizar los slopes (pendientes)

augment(Modelo_seleccionado) # Para mirar los coeficientes



#  Maneras de describir un modelo
# 1. Matemática
# 2. Geometrica 
# 3. Sintetica

# De la manera matemática se obtiene
# 1. Ecuación 
# 2. Residuos
# 3. Coeficientes

# Construir un modelo

Modelo<-lm(formula = Total ~ HP + Attack + Defense + Sp..Atk + Sp..Def, 
                        data = Pokemon_num)

# Ajuste del modelo , residuos y predicción


# Ajuste del modelo

Modelo%>%
  summary()
# EL R^2=1-sse/sst, indica el ajuste 

predict(Modelo)

# Creo una nueva observacdión

new_data=data.frame(HP=66,Attack=30,Defense=45,Sp..Atk=65,Sp..Def=65)
# Creo un modelo de predicción en donde mi y'Total' adquiere la siguiente forma

predict(Modelo, newdata = new_data)# Predicción 
augment(Modelo, newdata = new_data)# Argumentos 

argumentos=data.frame(augment(Modelo))


# Añadiendo interacciones a los mdoelos 
Pokemon$Legendary_d<-as.numeric(Pokemon$Legendary)
Modelo_sint<-lm(formula = Total ~ HP + Attack + Defense + Sp..Atk + Sp..Def+ Total:factor(Legendary_d), 
   data = Pokemon)

Modelo_sint%>%
  summary()















library(plotly)

# draw the 3D scatterplot
p <- plot_ly(data = Pokemon, z = ~Total, x = ~HP, y = ~Defense, opacity = 0.6) %>%
  add_markers() 

# draw the plane



# ¿ Qué es una regresión logística?
# Permite estimar la probabilidad de ina variable cuantitativa binaria 
# en función de las cuantitativas



Pokemon%>%
  ggplot(aes(Total,Legendary, color=Legendary))+
  geom_jitter(width = 0,height = .5,alpha=.4)+
  theme(legend.position = "bottom")


# Ajustar el modelo


glm(Legendary~Total+Attack+Defense + Sp..Atk + Sp..Def+Defense,data=Pokemon,family = binomial)

# Visualizar la regresión logística-------------------------
Pokemon$Legendary_d[Pokemon$Legendary_d==1]<-0
Pokemon$Legendary_d[Pokemon$Legendary_d==2]<-1

Pokemon%>%
  ggplot(aes(Total,Legendary_d))+
  geom_jitter(alpha=.4)+
  geom_smooth(method = "lm", col="red")+
  geom_smooth(method = "glm",se=200,
              method.args=list(family="binomial"))

# Notese que el modelo logístico quedo perfecto

Modelo<-glm(Legendary~Total+Attack+Defense + Sp..Atk + Sp..Def+Defense,data=Pokemon,family = binomial)

Pokemon%>%
  ggplot(aes(Total,Legendary_d))+
  geom_jitter(alpha=.4)+
  geom_smooth(method = "glm",se=FALSE,
              method.args=list(family="binomial"))+
  geom_line(data = augment(Modelo,type.predict = "response"),
            aes(y=.fitted),color="green")


# Escalas de interpretación

# 1. Respuesta 
# Es intuitivo y fácil de interpretar

Pokemon%>%
  ggplot(aes(Total,Legendary_d))+
  geom_jitter(alpha=.4)+
  geom_smooth(method = "glm",se=FALSE,
              method.args=list(family="binomial"))+
  geom_line(data = augment(Modelo,type.predict = "response"),
            aes(y=.fitted),color="green")

# 2. Posibilidades 
# Es dificil de interpretar


Modelo_plus<-Modelo%>%
  augment(type.predict="response")%>%
  mutate(y_hat=.fitted)

Modelo_plus<-Modelo_plus%>%
  mutate(odds_hat=y_hat/(1-y_hat))






# 

Modelo_plus%>%
  ggplot(aes(Total,odds_hat))+
  geom_line()+
  geom_point()+
  scale_y_continuous()


# Log Posibilidades
# Es imposible de interpretar en escala
# La lienalidad es fácil de interpretar

Modelo_plus<-Modelo_plus%>%
  mutate(log_odds_hat=log(odds_hat))

Modelo_plus%>%
  ggplot(aes(x=Total,y=log_odds_hat))+
  geom_point()+
  geom_line()



# Odds Ratio 

exp(coef(Modelo))



# Interpretación 
# Se crea una nueva base de datos para determinar si un nuevo pokemon es legenda o no

exp(coef(Modelo))
New_Pokemon<-data.frame(Total=400,Attack=70,Defense=60,
                        Sp..Atk=50,Sp..Def=50)

augment(Modelo,newdata=New_Pokemon,type.predict="response")

# La posibilidad de que sea una legenda es de 0.06%

# Mediante la matrix de confisión se encuentra lo siguiente

Modelo<-glm(Legendary_d~Total+Attack+Defense + Sp..Atk + Sp..Def+Defense,data=Pokemon,family = binomial)
Modelo_plus<-Modelo%>%
  augment(type.predict="response")%>%
  mutate(legend_hat=round(.fitted))

Modelo_plus%>%
  select(Legendary_d, Total,.fitted,legend_hat)


Modelo_plus%>%
  select(Legendary_d,legend_hat)%>%
  table()


#  Hay un total de 755 Pokemones 
#  donde 45 parecen ser legenda, pero en realidad solo 29 lo son
#  ELa exactitud del modelo es del 94%
# Calculon del accuracy: se suman todas las variables de la matriz de confusión y ese resultado se divide en los niveles de acierto

Accuracy<-sum(719,29)/sum(719+36+16+20)

Accuracy

