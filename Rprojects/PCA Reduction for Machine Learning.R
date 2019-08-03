# =======================================
# = Machine Learning  a través de PCA`s =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =            Merlin Jobs              =
# =            2019-08-023              =
# =======================================

rm(list = ls())
# Librerias -----------------------------------------


library(tidyverse); # Manipulación de datos
library(statisticalModeling); # Modelos Estadísticos
library(AnomalyDetection); # Anomalías 
library(infer) # Inferencia estadística
library(corrr) # Correlaciones 
library(corrplot) # Gráficos de correlación 
library(factoextra) # Análisis de componentes principales
library(FactoMineR) # Mineria de datos a nivel de modelos matemáticos
library(caret) # Modelos de Redes neuronales 
library( neuralnet ) # Libreria de redes neuronales
library(e1071) # Matriz dfe confusión
library(GGally) # >Gráfico de correlaciones
library(gridExtra)
library(ggpubr)



# Base de Datos ----------------------------------------

Pokemon<-read.csv("Documents/R/Bases de Datos/Pokemon.csv")%>%
  select(-X.)


# EDA --------------------------------------------------

Pokemon%>%
  dim()

# Variable respuesta 

Pokemon%>%
  glimpse()

Pokemon%>%
  ggplot(aes(Type.1,y=..count..,fill=Type.1))+
  geom_bar()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  guides(fill=FALSE)+
  labs(x="Tipo", y="Total", title = 'Tipo de Pokemon')


# Variables Continuas -------------------------

Pokemon%>%
  ggplot(aes(Total, fill=Type.1))+
  geom_density()+
  geom_rug(aes(color = Type.1), alpha = 0.5) +
  theme(legend.position = "bottom")



Pokemon%>%
  ggplot(aes(Type.1,Total,fill=Type.1))+
  geom_boxplot()+
  geom_jitter(alpha = 0.3, width = 0.15)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  theme(legend.position = "bottom")+
  labs(fill="Tipo", x="", y="Total")


# Descripción de las variables respuesta

Pokemon%>%
  group_by(Type.1)%>%
  summarize(Promedio=mean(Total),
            Mediana=median(Total),
            Varianza=var(Total),
            Mínimo=min(Total),
            Máximo=max(Total))


# Descipción cualitativa

Pokemon%>%
  ggplot(aes(x=Type.1,y=..count..,fill=Legendary))+
  geom_bar()+
  labs(x="Tipo", y='Total',title = 'Pokemon Legendary')+
  #theme(legend.position = "bottom")+
  scale_fill_manual(values = c("gray50", "orangered2"))+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Importancia de las variables 

M <-cor(Pokemon[,c(5:10)])
corrplot(M, type="upper", order="hclust")
source("http://www.sthda.com/upload/rquery_cormat.r")
rquery.cormat(Pokemon[,c(5:10)])

ggpairs(data=Pokemon,columns = c(5:10))

# Se gráfica la correlación más fuerte

Pokemon%>%
  ggplot(aes(Sp..Atk,Sp..Def))+
  geom_point(color="grey20")+
  geom_smooth(color="blue")+
  theme_bw()


# Contraste de proporciones

Pokemon%>%
  ggplot(aes(x=Type.1,y=..count..,fill=Legendary))+
  geom_bar()+
  labs(x="Tipo", y='Total',title = 'Pokemon Legendary')+
  scale_fill_manual(values = c("gray50", "orangered2"))+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



# Test de Proporcionalidad --------------------------
Pokemon%>%
  group_by(Type.1)%>%
  summarize(Total=n())%>%
  mutate(prop=Total/sum(Total))%>%
  arrange(desc(Total))



test_proporcion <- function(Pokemon){
  n_water <- sum(Pokemon$Type.1 == "Water") 
  n_other     <- sum(Pokemon$Type.1 != "Water")
  n_total <- n_water + n_other
  test <- prop.test(x = n_water, n = n_total, p = 0.14)
  prop_water <- n_water / n_total
  return(data.frame(p_value = test$p.value, prop_water))
}

Datos_cualitativos<-Pokemon%>%
  select(Name,Type.1,Type.2,Legendary)


datos_cualitativos_tidy <- Datos_cualitativos %>%
  gather(key = "variable", value = "grupo",-Type.1)

datos_cualitativos_tidy <- datos_cualitativos_tidy %>% filter(!is.na(grupo))

datos_cualitativos_tidy <- datos_cualitativos_tidy %>%
  mutate(variable_grupo = paste(variable, grupo, sep = "_"))



analisis_prop <- datos_cualitativos_tidy %>%
  group_by(variable_grupo) %>%
  nest() %>%
  arrange(variable_grupo) %>%
  mutate(prop_test = map(.x = data, .f = test_proporcion)) %>%
  unnest(prop_test) %>%
  arrange(p_value) %>% 
  select(variable_grupo,p_value, prop_water)


analisis_prop


# Análisis de las distribuciones

top_grupos <- analisis_prop %>% pull(variable_grupo) %>% head(10)
top_grupos

plot_grupo <- function(grupo, Pokemon, threshold_line = 0.14){
  
  p <- ggplot(data = Pokemon, aes(x = 1, y = ..count.., fill = Type.1)) +
    geom_bar() +
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

datos_graficos <- datos_cualitativos_tidy %>%
  filter(variable_grupo %in% top_grupos) %>%
  group_by(variable_grupo) %>%
  nest() %>%
  arrange(variable_grupo)

plots <- map2(datos_graficos$variable_grupo, .y = datos_graficos$data,
              .f = plot_grupo)

ggarrange(plotlist = plots, common.legend = TRUE)

# Random Forest
library(randomForest)

Datos_rf<-Pokemon%>%
  select(c(2,5:10))

Datos_rf <- map_if(.x = Datos_rf, .p = is.character, .f = as.factor) %>%
  as.data.frame()

Datos_rf

modelo_rf <- randomForest(formula = Type.1 ~ . ,
                                  data = Datos_rf,
                                  mtry = 5,
                                  importance = TRUE, 
                                  ntree = 1000) 

importancia <- as.data.frame(modelo_rf$importance)
importancia <- rownames_to_column(importancia,var = "variable")
importancia

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

# Las variables que importan Sp..Atk, Attack y Speed influyen sobre el type1

#  División de datos

set.seed(123)
train <- createDataPartition(y = Pokemon$Type.1, p = 0.8, list = FALSE, times = 1)
datos_train <- Pokemon[train, ]
datos_test  <- Pokemon[-train, ]

datos_train%>%
  select(c(2,5:10))->datos_train

datos_test%>%
  select(c(2,5:10))->datos_test

prop.table(table(datos_train$Type.1))
prop.table(table(datos_test$Type.1))

# Definir la variable respuesta

library(recipes)
objeto_recipe <- recipe(formula = Type.1 ~ .,
                        data =  datos_train)

objeto_recipe

# Varianza próxima a cero

Pokemon%>%
  select(c(5:10))%>%
  nearZeroVar(saveMetrics = TRUE)

# No hay un predictor cercano a cero



# Selección de predictores --------------------------
library(doMC)
registerDoMC(cores = 4)
repeticiones<-50
subsets <- c(1:4) # Conjunto de predictores

seeds <- vector(mode = "list", length = repeticiones + 1)
for (i in 1:repeticiones) {
  seeds[[i]] <- sample.int(100, length(subsets))
} 
seeds[[repeticiones + 1]] <- sample.int(100, 1)

# Función de control
ctrl_rfe <- rfeControl(functions = rfFuncs, method = "boot", number = repeticiones,
                       returnResamp = "all", allowParallel = TRUE, verbose = FALSE,
                       seeds = seeds)

# Eliminación recursiva
set.seed(342)
rf_rfe <- rfe(Type.1 ~ ., data = datos_train,
              sizes = c(3:10),
              metric = "Accuracy",
              # El accuracy es la proporción de clasificaciones correctas
              rfeControl = ctrl_rfe,
              ntree = 50)

ggplot(data = rf_rfe$results, aes(x = Variables, y = Accuracy)) +
  geom_line() +
  scale_x_continuous(breaks  = unique(rf_rfe$results$Variables)) +
  geom_point() +
  geom_errorbar(aes(ymin = Accuracy - AccuracySD, ymax = Accuracy + AccuracySD),
                width = 0.2) +
  geom_point(data = rf_rfe$results %>% slice(which.max(Accuracy)),
             color = "red") +
  theme_bw()


rf_rfe # Tabla de resumen 

rf_rfe$optVariables # Variables relevantes
# Mostró que todas las variables son relevantes

# Métricas por tamaño
rf_rfe$resample %>% group_by(Variables) %>%
  summarise(media_accuracy = mean(Accuracy),
            media_kappa = mean(Kappa)) %>%
  arrange(desc(media_accuracy))

# Parece no haber reducción recursiva



# Eliminación recursiva dos
set.seed(342)
rf_rfe_2 <- rfe(Type.1 ~ ., data = datos_train,
              sizes = c(5:6),
              metric = "Accuracy",
              # El accuracy es la proporción de clasificaciones correctas
              rfeControl = ctrl_rfe,
              ntree = 90)

ggplot(data = rf_rfe_2$results, aes(x = Variables, y = Accuracy)) +
  geom_line() +
  scale_x_continuous(breaks  = unique(rf_rfe_2$results$Variables)) +
  geom_point() +
  geom_errorbar(aes(ymin = Accuracy - AccuracySD, ymax = Accuracy + AccuracySD),
                width = 0.2) +
  geom_point(data = rf_rfe_2$results %>% slice(which.max(Accuracy)),
             color = "red") +
  theme_bw()


# Este método no ayudo 

rf_rfe_2$resample %>% group_by(Variables) %>%
  summarise(media_accuracy = mean(Accuracy),
            media_kappa = mean(Kappa)) %>%
  arrange(desc(media_accuracy))

# 
head(rf_rfe$variables, 10)

rf_rfe$variables %>% filter(Variables == 6) %>% group_by(var) %>%
  summarise(media_influencia = mean(Overall),
            sd_influencia = sd(Overall)) %>%
  arrange(desc(media_influencia))



# Paralelización
# =============================================================================
library(doMC)
registerDoMC(cores = 4)

# Control de entrenamiento
# =============================================================================
ga_ctrl <- gafsControl(functions = rfGA,
                       method = "cv",
                       number = 5,
                       allowParallel = TRUE,
                       genParallel = TRUE, 
                       verbose = FALSE)

# Selección de predictores
# =============================================================================
set.seed(10)
rf_ga <- gafs(x = datos_train[, -1],
              y = datos_train$Type.1,
              iters = 50, 
              popSize = 50,
              gafsControl = ga_ctrl,
              ntree = 100)

rf_ga # El ajuste no es más del 24%


rf_ga$optVariables


rf_ga$external %>% group_by(Iter) %>% summarize(accuracy_media = mean(Accuracy))



# Dado que el método no funciono, se trabajá con los datos como están en redes neuronales

# HIPERPARÁMETROS, NÚMERO DE REPETICIONES Y SEMILLAS PARA CADA REPETICIÓN
#===============================================================================
particiones  <- 10
repeticiones <- 5

# Hiperparámetros
hiperparametros <- expand.grid(size = c(10, 20, 50),
                               decay = c(0.0001, 0.1, 0.5))

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
modelo_nnet <- train(Type.1 ~ ., data = datos_train,
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

ggplot(modelo_nnet, highlight = TRUE) +
  labs(title = "Evolución del accuracy del modelo NNET") +
  theme_bw()

# El modelo tampoco ajusta por está vía

# Se desarrolla el PCA

Datos<-Pokemon%>%
  select(c(2,5:10))

Datos$Tipo<-as.numeric(Datos$Type.1)
Datos_2<-Datos%>%
  select(-Type.1)

index<-createDataPartition(Datos_2$Tipo,times = 1,list = FALSE,p = .8)

Datos_2[index,]->train
Datos_2[-index,]->test

testset = test %>% select( -Tipo )

n=names(train)
f = as.formula( paste( "Tipo ~", paste( n[!n %in% "Tipo"], collapse = "+" ) ) )
nn = neuralnet( f, train, hidden = 4, linear.output = FALSE, threshold = 0.01 )
plot( nn, rep = "best" )

nn$result.matrix[1,] # El error es muy alto

# Desarrollo del testeo

nn.results = compute( nn, testset )
results = data.frame( actual = test$Tipo, prediction = round( nn.results$net.result ) )
t = table( results )

# Desarrollo del PCA

pca_trainset = train %>% select( -Tipo )
pca_testset = testset
pca = prcomp( pca_trainset, scale = T )

# Calculo de la varianza

pr_var = ( pca$sdev )^2 

# Porcentaje de la varianza
prop_varex = pr_var / sum( pr_var )
prop_varex
plot( prop_varex, xlab = "Principal Component", 
      ylab = "Proportion of Variance Explained", type = "b" )

plot( cumsum( prop_varex ), xlab = "Principal Component", 
      ylab = "Cumulative Proportion of Variance Explained", type = "b" )



# Creating a new dataset
train = data.frame( class = train$Tipo, pca$x )
t = as.data.frame( predict( pca, newdata = pca_testset ) )

new_trainset = train
new_testset =  t

# Construir con la red con los componentes principales

n = names( new_trainset )
f = as.formula( paste( "class ~", paste( n[!n %in% "class" ], collapse = "+" ) ) )
nn = neuralnet( f, new_trainset, hidden = 4, linear.output = FALSE, threshold=0.01 )

# Plot the NN
plot( nn, rep = "best" )
nn$result.matrix[1,]  # El error sigue siendo alto
nn.results = compute( nn, new_testset )
t = table( results )

