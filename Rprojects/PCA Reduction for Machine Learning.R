# =======================================
# = Machine Learning  a través de PCA`s =
# =           Daniel Jiménez            =
# =         Senior Data Scientist       =
# =            Merlin Jobs              =
# =            2019-08-03               =
# =======================================


# Librerias -----------------------------------------

rm(list = ls())
library(tidyverse); # Manipulación de datos
library(corrr) # Correlaciones 
library(corrplot) # Gráficos de correlación 
library(factoextra) # Análisis de componentes principales
library(FactoMineR) # Mineria de datos a nivel de modelos matemáticos
library(caret) # Modelos de Redes neuronales 
library( neuralnet ) # Libreria de redes neuronales
library(e1071) # Matriz dfe confusión


# Importar Baser de datos 


Pokemon<-read.csv("Documents/R/Bases de Datos/Pokemon.csv")%>%
  select(-X.)


# Se desea clasificar a los pokemones 'Water'

Pokemon%>%
  select(c(2,5:10))->Pokemon_tidy

Pokemon_tidy$Type.1<-as.character(Pokemon$Type.1)
Pokemon_tidy$Type.1[Pokemon$Type.1!="Water"]<-"Other"

Pokemon_tidy%>%
  count(Type.1, sort = TRUE) %>%
  mutate(Prop=n/sum(n))

# Se crea la variable de interés en forma de función


Pokemon_obj<-Pokemon_tidy%>%
  filter(Type.1=="Other"|Type.1=="Water")%>%
  transform(Type.1=ifelse(Type.1=="Water",0,1))

Pokemon_obj = as.data.frame( sapply( Pokemon_obj, as.numeric ) )

# Se crea partición de la base de datos

index<-createDataPartition(Pokemon_obj$Type.1, times = 1,list = FALSE,p = .8)
Pokemon_obj[index,]->Prueba
Pokemon_obj[-index,]->Testeo

testset = Testeo %>% select( -Type.1 )


# Se construye la red neuronal

n = names(Prueba)
f = as.formula( paste( "Type.1 ~", paste( n[!n %in% "Type.1"], collapse = "+" )) )
nn = neuralnet( f, Prueba, hidden = 4, linear.output = FALSE, threshold = 0.01 )
plot( nn, rep = "best" )

# Prueba del resultado

nn_results = compute( nn, testset )
results = data.frame( actual = Testeo$Type.1, prediction = nn_results$net.result)




# NO clasifica bien


# Resultado con PCA

# PCA
pca_trainset = Prueba %>% select( -Type.1 )
pca_testset = testset
pca = prcomp( pca_trainset, scale = T )

# variance
pr_var = ( pca$sdev )^2 

# % of variance
prop_varex = pr_var / sum( pr_var )

# Plot
plot( prop_varex, xlab = "Principal Component", 
      ylab = "Proportion of Variance Explained", type = "b" )


plot( cumsum( prop_varex ), xlab = "Principal Component", 
      ylab = "Cumulative Proportion of Variance Explained", type = "b" )




# Creating a new dataset
train = data.frame( class = Prueba$Type.1, pca$x )
t = as.data.frame( predict( pca, newdata = pca_testset ) )

new_trainset = train[,1:7]
new_testset =  t[,1:6]

# Build the neural network (NN)

n = names( new_trainset )
f = as.formula( paste( "class ~", paste( n[!n %in% "class" ], collapse = "+" ) ) )
nn = neuralnet( f, new_trainset, hidden = 4, linear.output = FALSE, threshold=0.01 )

# Plot the NN
plot( nn, rep = "best" )


nn.results = compute( nn, new_testset )

# Results
results = data.frame( actual = Testeo$Type.1, 
                      prediction = round( nn.results$net.result ) )


x<-as.integer(results$prediction)
y<-results$actual
u<-union(x,y)
Tabla<-table(factor(x,u),factor(y,u))
confusionMatrix(Tabla)






