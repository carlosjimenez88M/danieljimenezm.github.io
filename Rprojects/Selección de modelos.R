# =======================================
# =      Selección de modelos           =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =            Merlin Jobs              =
# =              2019-08-06             =
# =======================================




# Librerias ------------------------------------
(install.packages("h2o"))
library(h2o)
library(tidyverse)
library(caret)
library(corrr)
library(ggpubr)

# Para trabajar con h20, hjay que establecer con cuantos cores van a trabajar en forma de cluster


# Cargar bases de datos Prueba

Pokemon<-read.csv("Documents/R/Bases de Datos/Pokemon.csv")%>%
  select(-X.)

# Estructura de la base de datos ------------------------

Pokemon%>%
  glimpse()


# Análisis exploratorio de datos

Pokemon%>%
  summary()

# ¿ Cuáles son los pokemones con mayor poder?

Pokemon%>%
  group_by(Type.1)%>%
  summarize(Total=sum(Total))%>%
  arrange(desc(Total))%>%
  mutate(Type.1=fct_reorder(Type.1,Total))%>%
  ggplot(aes(Type.1,Total,fill=Type.1))+
  geom_col()+
  guides(fill=FALSE)+
  coord_flip()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  labs(x="Tipo de Pokemon", y="Poder",title = 'Pokemones ordenamos por más poderosos')





# Se desea desarrollar un análisis que determine si un Pokemon es de Agua o no

Pokemon$tipo<-if_else(Pokemon$Type.1=="Water", "Si","No")
Pokemon$tipo<-as.factor(Pokemon$tipo)

# Dimensión de la base de datos


dim(Pokemon)

# Se explora si hay datos faltantes
any(!complete.cases(Pokemon))
# No hay Valores Ausentes


map_dbl(Pokemon,.f = function(x){sum(is.na(x))})


# Variable Respuesta

Pokemon%>%
  group_by(tipo)%>%
  summarize(Total=n())%>%
  ggplot(aes(tipo,Total, fill=tipo))+
  geom_col()+
  geom_text(aes(label=Total),position = position_stack(vjust = .5))+
  labs(title = "Conteo de pokemones\n de Agua")+
  guides(fill=FALSE)


# Visto desde el comportamiento porcentual

Pokemon%>%
  group_by(tipo)%>%
  summarize(Total=n())%>%
  mutate(Porc=Total/sum(Total))


# Porcentaje de acierto sobre el número de pokemones que son de agua

n<-dim(Pokemon)[1]
prediccion<-rep(x="Si",n)
mean(prediccion==Pokemon$tipo)  

# Análisis Visual

Pokemon%>%
  ggplot(aes(HP,fill=tipo))+
  geom_density(alpha=.3)+
  geom_rug(aes(col=tipo),alpha=.3)+
  theme(legend.position = 'bottom')->Uno

Pokemon%>%
  ggplot(aes(tipo,HP,color=tipo))+
  geom_jitter(alpha=.3,width = .1)+
  geom_boxplot(outlier.shape = NA)+
  theme(legend.position = 'bottom')->Dos


ggarrange(Uno,Dos)


# Estadísticos del tipo

Pokemon%>%
  group_by(tipo)%>%
  summarize(Promedio=mean(Total),
            Mediana=median(Total),
            Min=min(Total),
            Max=max(Total))



# Importancia de las variables


correlate(Pokemon[,4:10])->Correlacion

Correlacion%>%
  rearrange()%>%
  shave()

fashion(Correlacion)

Correlacion%>%
  rplot()




Correlacion%>%
  network_plot(min_cor = .1)




# Importancia de las variables


cor.test(Pokemon$Defense, Pokemon$Total,method = 'pearson')



Pokemon%>%
  ggplot(aes(Total,Defense))+
  geom_jitter(alpha=.2)+
  geom_smooth(color="blue")



# Se seleccionan los datos cuantitativos

Pokemon_num<-Pokemon%>%
  select(4:10,13)

Pokemon_tidy<-Pokemon_num%>%
  gather(key = "Clase",value="Variable",-tipo)

Pokemon_tidy<- Pokemon_tidy%>%
  mutate(variable_grupo = paste(Clase, Variable, sep = "_"))




# Test de proporcionalidad


test_proporcion <- function(Pokemon){
  n_Agua <- sum(Pokemon$tipo == "Si") 
  n_Otros<- sum(Pokemon$tipo == "No")
  n_total <- n_Agua + n_Otros
  test <- prop.test(x = n_Agua, n = n_total, p = 0.86)
  prop_Agua <- n_Agua / n_total
  return(data.frame(p_value = test$p.value, prop_Agua))
}


# Análisis de proporcionalidad


analisis_prop <- Pokemon_tidy %>%
  group_by(variable_grupo) %>%
  nest() %>%
  arrange(variable_grupo) %>%
  mutate(prop_test = map(.x = data, .f = test_proporcion)) %>%
  unnest(prop_test) %>%
  arrange(p_value) %>% 
  select(variable_grupo,p_value, prop_Agua)

analisis_prop 


# Representación de los p valores más pequeños

top_grupos <- analisis_prop %>% pull(variable_grupo) %>% head(10)
top_grupos

plot_grupo <- function(grupo, Pokemon, threshold_line = 0.86){
  
  p <- ggplot(data = Pokemon, aes(x = 1, y = ..count.., fill = tipo)) +
    geom_bar() +
    scale_fill_manual(values = c("gray50", "orangered2")) +
    # Se añade una línea horizontal en el nivel basal
    geom_hline(yintercept = nrow(Pokemon) * threshold_line,
               linetype = "dashed") +
    labs(title = grupo) +
    theme_bw() +
    theme(legend.position = "bottom",
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.x = element_blank())
  return(p)
}



datos_graficos <- Pokemon_tidy %>%
  filter(variable_grupo %in% top_grupos) %>%
  group_by(variable_grupo) %>%
  nest() %>%
  arrange(variable_grupo)


plots <- map2(datos_graficos$variable_grupo, .y = datos_graficos$data,
              .f = plot_grupo)
ggarrange(plotlist = plots, common.legend = TRUE)
# Se creo la función que determine si son de agua o no a través de los p valores más pequeños


# Random Forest 

datos_rf<-Pokemon_num%>%
  map_if(.p=is.character,.f=as.factor)

datos_rf

modelo_randforest <- randomForest(formula = tipo ~ . ,
                                  data = na.omit(datos_rf),
                                  mtry = 5,
                                  importance = TRUE, 
                                  ntree = 1000) 


importancia <- as.data.frame(modelo_randforest$importance)
importancia <- rownames_to_column(importancia,var = "variable")


p1 <- ggplot(data = importancia, aes(x = reorder(variable, MeanDecreaseAccuracy),
                                     y = MeanDecreaseAccuracy,
                                     fill = MeanDecreaseAccuracy)) +
  labs(x = "variable", title = "Reducción de Accuracy") +
  geom_col() +
  coord_flip() +
  theme_bw() +
  theme(legend.position = "bottom")

p2 <- ggplot(data = importancia, aes(x = reorder(variable, MeanDecreaseGini),
                                     y = MeanDecreaseGini,
                                     fill = MeanDecreaseGini)) +
  labs(x = "variable", title = "Reducción de pureza (Gini)") +
  geom_col() +
  coord_flip() +
  theme_bw() +
  theme(legend.position = "bottom")
ggarrange(p1, p2)

# Las Variables Total, Sp..Defense y Speed determinan si son de agua los pokemones


# División de datos
set.seed(123)

train<-createDataPartition(Pokemon$tipo,times = 1,list = FALSE,p = .8)

Datos_train<-Pokemon[train,]
Datos_test<-Pokemon[-train,]

prop.table(table(Datos_train$tipo))
prop.table(table(Datos_test$tipo))

# Variables con varianza proxima a cero

Pokemon_num%>%
  nearZeroVar(saveMetrics = TRUE)

# Crear objeto
library(recipes)
objeto<-recipe(tipo~Total+Sp..Def+Speed+HP, data=Datos_train)

objeto
#objeto_recipe <- objeto %>% step_bagimpute(Total_grupo)

objeto_recipe <- objeto %>% step_nzv(all_predictors())

# Estandarización

objeto_recipe <- objeto_recipe %>% step_center(all_numeric())
objeto_recipe <- objeto_recipe %>% step_scale(all_numeric())

# Binarización 
objeto_recipe <- objeto_recipe %>% step_dummy(all_nominal(), -all_outcomes())

# Entrenamiento del objeto recipe

trained_recipe <- prep(objeto_recipe, training = Datos_train)
trained_recipe


# transformación al conjunto de datos
datos_train_prep <- bake(trained_recipe, new_data = Datos_test)
datos_test_prep  <- bake(trained_recipe, new_data = Datos_test)


glimpse(datos_train_prep)

# Hay cuatro variables predictoras y una respuesta


# Selección de predictores ----------------------------
# Eliminación Recursiva 

library(doMC)
registerDoMC(cores = 4)

# Tamaño de los predictores seleccionados

subsets <- c(2:4)

# Remuestreo

repeticiones <- 50

set.seed(123)
seeds <- vector(mode = "list", length = repeticiones + 1)
for (i in 1:repeticiones) {
  seeds[[i]] <- sample.int(1000, length(subsets))
} 
seeds[[repeticiones + 1]] <- sample.int(100, 1)

# Control de entrenamiento

ctrl_rfe <- rfeControl(functions = rfFuncs, method = "boot", number = repeticiones,
                       returnResamp = "all", allowParallel = TRUE, verbose = FALSE,
                       seeds = seeds)


# Se ejecuta la eliminación recursiva de predictores
set.seed(342)
rf_rfe <- rfe(tipo ~ ., data = datos_train_prep,
              sizes = subsets,
              metric = "Accuracy",
              # El accuracy es la proporción de clasificaciones correctas
              rfeControl = ctrl_rfe,
              ntree = 500)
rf_rfe

rf_rfe$optVariables # estas son las mejores tres variables para la predicción del modelo

# Métricas promedio por cada tamaño

rf_rfe$resample %>% group_by(Variables) %>%
  summarise(media_accuracy = mean(Accuracy),
            media_kappa = mean(Kappa)) %>%
  arrange(desc(media_accuracy))



ggplot(data = rf_rfe$results, aes(x = Variables, y = Accuracy)) +
  geom_line() +
  scale_x_continuous(breaks  = unique(rf_rfe$results$Variables)) +
  geom_point() +
  geom_errorbar(aes(ymin = Accuracy - AccuracySD, ymax = Accuracy + AccuracySD),
                width = 0.2) +
  geom_point(data = rf_rfe$results %>% slice(which.max(Accuracy)),
             color = "red") +
  theme_bw()


rf_rfe$variables %>% filter(Variables == 3) %>% 
  group_by(var) %>%
  summarise(media_influencia = mean(Overall),
            sd_influencia = sd(Overall)) %>%
  arrange(desc(media_influencia))


# Algoritmo Genético

library(doMC)
registerDoMC(cores = 4)

# Control de entrenamiento
ga_ctrl <- gafsControl(functions = rfGA,
                       method = "cv",
                       number = 5,
                       allowParallel = TRUE,
                       genParallel = TRUE, 
                       verbose = FALSE)

# Selección de predictores
set.seed(10)
rf_ga <- gafs(x = datos_train_prep[, -5],
              y = datos_train_prep$tipo,
              iters = 10, 
              popSize = 10,
              gafsControl = ga_ctrl,
              ntree = 100)


rf_ga

rf_ga$optVariables
rf_ga$external %>% group_by(Iter) %>% summarize(accuracy_media = mean(Accuracy))



crear_poblacion <- function(popSize, n_variables, n_max){
  # Esta función crea una matriz binaria en la que el número de 1s por
  # fila no supera un valor máximo.
  # Argumentos:
  #   popSize:     número total de individuos (número de filas de la matriz).
  #   n_variables: longitud de los individuos (número de columnas de la matriz).
  #   n_max:       número máximo de 1 que puede contener un individuo.
  
  # Matriz donde almacenar los individuos generados.
  poblacion <- matrix(data = NA, nrow = popSize, ncol = n_variables)
  
  # Bucle para crear cada individuo.   
  for(i in 1:popSize){
    # Se selecciona con (igual probabilidad ) el número de valores = 1 que puede
    # tener el individuo.
    numero_1s <- sample(x = 1:n_max, size = 1)
    
    # Se crea un vector con todo ceros que representa el individuo.
    individuo <- rep(0, times = n_variables)
    
    # Se sustituyen (numero_1s) posiciones aleatorias por unos.
    individuo[sample(x = 1:n_variables, size = numero_1s)] <- 1
    
    # Se añade el nuevo individuo a la población.
    poblacion[i,] <- individuo
  }
  return(poblacion)
}


poblacion_inicial <- crear_poblacion(popSize = 10,
                                     n_variables = ncol(datos_train_prep) - 1 ,
                                     n_max = 4)
poblacion_inicial


set.seed(10)
rf_ga <- gafs(x = datos_train_prep[, -5],
              y = datos_train_prep$tipo,
              iters = 10, 
              popSize = 10,
              suggestions = poblacion_inicial,
              gafsControl = ga_ctrl,
              ntree = 100)
rf_ga


# Creación del modelo


# Support Vector Machine que predice el número de pokemones de agua en base a los predictores

modelo_svmlineal <- train(tipo ~ ., method = "svmLinear", data = datos_train_prep)

modelo_svmlineal$finalModel
# El error en el SVM es del 13%

# Evaluación del modelo mediante resampling ---------------------------

particiones  <- 10;
repeticiones <- 5;

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  # Cada elemento de la lista, excepto el último tiene que tener tantas semillas
  # como hiperparámetros analizados. En este caso, se emplea el valor por 
  # defecto C = 1, por lo que cada elemento de seeds está formada por un
  # único valor.
  seeds[[i]] <- sample.int(1000, 1) 
}

seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)

# Entrenamiento

control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "all", verboseIter = FALSE,
                              allowParallel = TRUE)
# Ajuste del modelo


set.seed(342)
modelo_svmlineal <- train(tipo ~ ., data = datos_train_prep,
                          method = "svmLinear",
                          metric = "Accuracy",
                          trControl = control_train)
modelo_svmlineal

modelo_svmlineal$resample %>% head(10)
summary(modelo_svmlineal$resample$Accuracy)


p1 <- ggplot(data = modelo_svmlineal$resample, aes(x = Accuracy)) +
  geom_density(alpha = 0.5, fill = "gray50") +
  geom_vline(xintercept = mean(modelo_svmlineal$resample$Accuracy),
             linetype = "dashed") +
  theme_bw() 
p2 <- ggplot(data = modelo_svmlineal$resample, aes(x = 1, y = Accuracy)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.5, fill = "gray50") +
  geom_jitter(width = 0.05) +
  labs(x = "") +
  theme_bw() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

final_plot <- ggarrange(p1, p2)
final_plot <- annotate_figure(
  final_plot,
  top = text_grob("Accuracy obtenido en la validación", size = 15))
final_plot


# Optimización por hiperparámetros

particiones  <- 10
repeticiones <- 5

hiperparametros <- data.frame(C = c(0.001, 0.01, 0.1, 0.5, 1, 10))


set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros)) 
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)



control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "all", verboseIter = FALSE,
                              allowParallel = TRUE)


set.seed(342)


modelo_svmlineal <- train(tipo ~ ., data = datos_train_prep,
                          method = "svmLinear",
                          tuneGrid = hiperparametros,
                          metric = "Accuracy",
                          trControl = control_train)
modelo_svmlineal

ggplot(data = modelo_svmlineal$resample,
       aes(x = as.factor(C), y = Accuracy, color = as.factor(C))) +
  geom_boxplot(outlier.shape = NA, alpha = 0.6) +
  geom_jitter(width = 0.2, alpha = 0.6) +
  # Línea horizontal en el accuracy basal
  geom_hline(yintercept = 0.82, linetype = "dashed") +
  labs(x = "C") +
  theme_bw() + theme(legend.position = "none")


set.seed(123)
hiperparametros <- data.frame(C = runif(n = 5, min = 0.001, max = 20))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros)) 
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)


control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "all", verboseIter = FALSE,
                              allowParallel = TRUE)




set.seed(342)
modelo_svmlineal_random <- train(tipo ~ ., data = datos_train_prep,
                                 method = "svmLinear",
                                 tuneGrid = hiperparametros,
                                 metric = "Accuracy",
                                 trControl = control_train)


modelo_svmlineal_random



# Predicción del modelo

predicciones_raw <- predict(modelo_svmlineal, newdata = datos_test_prep,
                            type = "raw")
predicciones_raw



particiones  <- 10
repeticiones <- 5
hiperparametros <- expand.grid(C = c(1))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros)) 
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)

control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "all", verboseIter = FALSE,
                              classProbs = TRUE, allowParallel = TRUE)

set.seed(342)
modelo_svmlineal <- train(tipo ~ ., data = datos_train_prep,
                          method = "svmLinear",
                          tuneGrid = hiperparametros,
                          metric = "Accuracy",
                          trControl = control_train)

predicciones_prob <- predict(modelo_svmlineal, newdata = datos_test_prep,
                             type = "prob")
predicciones_prob %>% head()


predicciones <- extractPrediction(
  models = list(svm = modelo_svmlineal),
  testX = datos_test_prep[, -5],
  testY = datos_test_prep$tipo
)
predicciones %>% head()



# Validación del modelo



confusionMatrix(data = predicciones_raw, reference = datos_test_prep$tipo,
                positive = "Si")

# El modelo no sirve


#KNN

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- data.frame(k = c(1:5))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(100, nrow(hiperparametros)) 
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_knn <- train(tipo ~ ., data = datos_train_prep,
                    method = "knn",
                    tuneGrid = hiperparametros,
                    metric = "Accuracy",
                    trControl = control_train)
modelo_knn


ggplot(modelo_knn, highlight = TRUE) +
  scale_x_continuous(breaks = hiperparametros$k) +
  labs(title = "Evolución del accuracy del modelo KNN", x = "K") +
  theme_bw()


# Naive Bayes




particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- data.frame(usekernel = FALSE, fL = 0 , adjust = 0)

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(100, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)



control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)


set.seed(342)
modelo_nb <- train(tipo ~ ., data = datos_train_prep,
                   method = "nb",
                   tuneGrid = hiperparametros,
                   metric = "Accuracy",
                   trControl = control_train)
modelo_nb


# Logística

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- data.frame(parameter = "none")

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# Modelo

set.seed(342)
modelo_logistic <- train(tipo ~ ., data = datos_train_prep,
                         method = "glm",
                         tuneGrid = hiperparametros,
                         metric = "Accuracy",
                         trControl = control_train,
                         family = "binomial")
modelo_logistic
summary(modelo_logistic$finalModel)

# Tiene el mejor nivel de ajuste

# Modelo LDA -----------------------------------------

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- data.frame(parameter = "none")

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(100, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_lda <- train(tipo ~ ., data = datos_train_prep,
                    method = "lda",
                    tuneGrid = hiperparametros,
                    metric = "Accuracy",
                    trControl = control_train)
modelo_lda
# Tiene mucho mejor ajuste



# Árbol de clasificación

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- data.frame(parameter = "none")

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(100, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(1000, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_C50Tree <- train(tipo ~ ., data = datos_train_prep,
                        method = "C5.0Tree",
                        tuneGrid = hiperparametros,
                        metric = "Accuracy",
                        trControl = control_train)
modelo_C50Tree
# Tiene mejor ajuste


summary(modelo_C50Tree$finalModel)


# Random Forest

hiperparametros <- expand.grid(mtry = c(1:4),
                               min.node.size = c(2, 3, 4, 5, 10, 15, 20, 30),
                               splitrule = "gini")

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(1000, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_rf <- train(tipo ~ ., data = datos_train_prep,
                   method = "ranger",
                   tuneGrid = hiperparametros,
                   metric = "Accuracy",
                   trControl = control_train,
                   # Número de árboles ajustados
                   num.trees = 500)
modelo_rf


modelo_rf$finalModel


ggplot(modelo_rf, highlight = TRUE) +
  scale_x_continuous(breaks = 1:30) +
  labs(title = "Evolución del accuracy del modelo Random Forest") +
  guides(color = guide_legend(title = "mtry"),
         shape = guide_legend(title = "mtry")) +
  theme_bw()


# El modelo queda ajustado en 86,83

#Gradiente

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- expand.grid(interaction.depth = c(1, 2),
                               n.trees = c(500, 1000, 2000),
                               shrinkage = c(0.001, 0.01, 0.1),
                               n.minobsinnode = c(2, 5, 15))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(1000, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_boost <- train(tipo ~ ., data = datos_train_prep,
                      method = "gbm",
                      tuneGrid = hiperparametros,
                      metric = "Accuracy",
                      trControl = control_train,
                      # Número de árboles ajustados
                      distribution = "adaboost",
                      verbose = FALSE)
modelo_boost


ggplot(modelo_boost, highlight = TRUE) +
  labs(title = "Evolución del accuracy del modelo Gradient Boosting") +
  guides(color = guide_legend(title = "shrinkage"),
         shape = guide_legend(title = "shrinkage")) +
  theme_bw() +
  theme(legend.position = "bottom")


# SVM

particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- expand.grid(sigma = c(0.001, 0.01, 0.1, 0.5, 1),
                               C = c(1 :4))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(1000, 1)

# DEFINICIÓN DEL ENTRENAMIENTO
#===============================================================================
control_train <- trainControl(method = "repeatedcv", number = particiones,
                              repeats = repeticiones, seeds = seeds,
                              returnResamp = "final", verboseIter = FALSE,
                              allowParallel = TRUE)

# AJUSTE DEL MODELO
# ==============================================================================
set.seed(342)
modelo_svmrad <- train(tipo ~ ., data = datos_train_prep,
                       method = "svmRadial",
                       tuneGrid = hiperparametros,
                       metric = "Accuracy",
                       trControl = control_train)
modelo_svmrad


modelo_svmrad$finalModel



ggplot(modelo_svmrad, highlight = TRUE) +
  labs(title = "Evolución del accuracy del modelo SVM Radial") +
  theme_bw()


# Red Neuronal
hiperparametros <- expand.grid(size = c(10, 20, 50, 80, 100, 120),
                               decay = c(0.0001, 0.1, 0.5))

set.seed(123)
seeds <- vector(mode = "list", length = (particiones * repeticiones) + 1)
for (i in 1:(particiones * repeticiones)) {
  seeds[[i]] <- sample.int(1000, nrow(hiperparametros))
}
seeds[[(particiones * repeticiones) + 1]] <- sample.int(1000, 1)


control_train <- trainControl(method = "repeatedcv", number = particiones,
                             repeats = repeticiones, seeds = seeds,
                             returnResamp = "final", verboseIter = FALSE,
                             allowParallel = TRUE)


set.seed(342)
modelo_nnet <- train(tipo ~ ., data = datos_train_prep,
                     method = "nnet",
                     tuneGrid = hiperparametros,
                     metric = "Accuracy",
                     trControl = control_train,
                     # Rango de inicialización de los pesos
                     rang = c(-0.7, 0.7),
                     # Número máximo de pesos
                     # se aumenta para poder incluir más meuronas
                     MaxNWts = 2000,
                     # Para que no se muestre cada iteración por pantalla
                     trace = FALSE)
modelo_nnet



modelos <- list(KNN = modelo_knn, NB = modelo_nb, logistic = modelo_logistic,
                LDA = modelo_lda, arbol = modelo_C50Tree, rf = modelo_rf,
                boosting = modelo_boost, SVMradial = modelo_svmrad,
                NNET = modelo_nnet)

resultados_resamples <- resamples(modelos)
resultados_resamples$values %>% head(10)


metricas_resamples <- resultados_resamples$values %>%
  gather(key = "modelo", value = "valor", -Resample) %>%
  separate(col = "modelo", into = c("modelo", "metrica"),
           sep = "~", remove = TRUE)
metricas_resamples %>% head()



metricas_resamples %>% 
  group_by(modelo, metrica) %>% 
  summarise(media = mean(valor)) %>%
  spread(key = metrica, value = media) %>%
  arrange(desc(Accuracy))



metricas_resamples %>%
  filter(metrica == "Accuracy") %>%
  group_by(modelo) %>% 
  summarise(media = mean(valor)) %>%
  ggplot(aes(x = reorder(modelo, media), y = media, label = round(media, 2))) +
  geom_segment(aes(x = reorder(modelo, media), y = 0,
                   xend = modelo, yend = media),
               color = "grey50") +
  geom_point(size = 7, color = "firebrick") +
  geom_text(color = "white", size = 2.5) +
  scale_y_continuous(limits = c(0, 1)) +
  # Accuracy basal
  geom_hline(yintercept = 0.8, linetype = "dashed") +
  annotate(geom = "text", y = 0.72, x = 8.5, label = "Accuracy basal") +
  labs(title = "Validación: Accuracy medio repeated-CV",
       subtitle = "Modelos ordenados por media",
       x = "modelo") +
  coord_flip() +
  theme_bw()



metricas_resamples %>% filter(metrica == "Accuracy") %>%
  group_by(modelo) %>% 
  mutate(media = mean(valor)) %>%
  ungroup() %>%
  ggplot(aes(x = reorder(modelo, media), y = valor, color = modelo)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.6) +
  scale_y_continuous(limits = c(0, 1)) +
  # Accuracy basal
  geom_hline(yintercept = 0.82, linetype = "dashed") +
  annotate(geom = "text", y = 0.65, x = 8.5, label = "Accuracy basal") +
  theme_bw() +
  labs(title = "Validación: Accuracy medio repeated-CV",
       subtitle = "Modelos ordenados por media") +
  coord_flip() +
  theme(legend.position = "none")




matriz_metricas <- metricas_resamples %>% filter(metrica == "Accuracy") %>%
  spread(key = modelo, value = valor) %>%
  select(-Resample, -metrica) %>% as.matrix()
friedman.test(y = matriz_metricas)




metricas_accuracy <- metricas_resamples %>% filter(metrica == "Accuracy")
comparaciones  <- pairwise.wilcox.test(x = metricas_accuracy$valor, 
                                       g = metricas_accuracy$modelo,
                                       paired = TRUE,
                                       p.adjust.method = "holm")

# Se almacenan los p_values en forma de dataframe
comparaciones <- comparaciones$p.value %>%
  as.data.frame() %>%
  rownames_to_column(var = "modeloA") %>%
  gather(key = "modeloB", value = "p_value", -modeloA) %>%
  na.omit() %>%
  arrange(modeloA) 

comparaciones


# Error Test
predicciones <- extractPrediction(
  models = modelos,
  testX = datos_test_prep[, -5],
  testY = datos_test_prep$tipo
)
predicciones %>% head()



metricas_predicciones <- predicciones %>%
  mutate(acierto = ifelse(obs == pred, TRUE, FALSE)) %>%
  group_by(object, dataType) %>%
  summarise(accuracy = mean(acierto))

metricas_predicciones %>%
  spread(key = dataType, value = accuracy) %>%
  arrange(desc(Test))

metricas_predicciones

ggplot(data = metricas_predicciones,
       aes(x = object, y = accuracy,
           color = dataType, label = round(accuracy, 2)))+ 
  geom_point(size = 8) +
  scale_color_manual(values = c("orangered2", "gray50")) +
  geom_text(color = "white", size = 3) +
  scale_y_continuous(limits = c(0, 1)) +
  # Accuracy basal
  geom_hline(yintercept = 0.62, linetype = "dashed") +
  annotate(geom = "text", y = 0.66, x = 8.5, label = "Accuracy basal") +
  coord_flip() +
  labs(title = "Accuracy de entrenamiento y test", 
       x = "modelo") +
  theme_bw() + 
  facet_wrap( ~dataType)+
  theme(legend.position = "bottom")


library(pROC)
#install.packages("pROC")

predicciones <- predict(object = modelo_boost,
                        newdata = datos_test_prep,
                        type = "prob")
curva_roc <- roc(response = datos_test_prep$tipo, 
                 predictor = predicciones$Si)


plot(curva_roc)
auc(curva_roc)
ci.auc(curva_roc, conf.level = 0.95)
