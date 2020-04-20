---
title: "PCA Tidymodels"
output: html_document
---




Es de reconocer que soy un gran fanático del trabajo de [Julia Silge](https://juliasilge.com/), quien hace poco empezo a trabajar como software engineer en R Studio. Su comprensión de la estadística es profundo y su capacidad de desarrollo de esta herramienta y generar una experiencia en `tidymodels` es de sobrada admiración.

En su nuevo post sobre la aplicación del **Principal Component Analysis** sobre canciones de Hip Hop vía `recipes` es un caso de estudio el cual abordaré de manera desagregada.



## ¿ En qué consiste los PCAs?

Una definición muy acertada que alberga [wikipedia](https://es.wikipedia.org/wiki/An%C3%A1lisis_de_componentes_principales) es la siguiente :

>"Es una técnica utilizada para describir un conjunto de datos en términos de nuevas variables no correlacionadas"


Esto llevado al plano de Machine Learning tiene un gran potencial. Lo importante en esta técnica es la capacidad que tiene para reducir la dimensionalidad de los datos.

Otra definición que vale la pena rescatar es dada por [Joaquín Amat](https://www.cienciadedatos.net/documentos/35_principal_component_analysis), en donde la describe de la siguiente manera:

>"Es un método estadístico que permite simplificar la complejidad de las variables de los espacios muestrales, a través de muchas dimensiones que conservan la información"

La información en estos términos debe leerse como: Varianza. Dicho de otro modo Los PCAs son dichas técnicas que logran simplificar los set de datos vía un número menor de features en un número optimo de componentes.

### Componentes de los PCAs.

* Eigenvector: Una forma simple de entender los vectores propios es la de dotadores de dirección

* Eigenvalue: los valores propios es la que indica cuanta varianza hay en los datos del eigenvector.


### una aproximación del PCA

Un ejemplo simple para entender esta técnica es la siguiente, se usará la base de datos `mtcars` que viene por defecto en R.

Se seleccionaran nueve variables para este proceso y se usará la función [prcomp](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/prcomp), la cual dada una matriz, retorna los resultados como objetos de los componentes.

{% highlight r %}
cars_PCA<-prcomp(mtcars[,c(1:7,10,11)], center = TRUE,scale. = TRUE)
cars_PCA%>%
  summary()
{% endhighlight %}



{% highlight text %}
## Importance of components:
##                           PC1    PC2
## Standard deviation     2.3782 1.4429
## Proportion of Variance 0.6284 0.2313
## Cumulative Proportion  0.6284 0.8598
##                            PC3     PC4
## Standard deviation     0.71008 0.51481
## Proportion of Variance 0.05602 0.02945
## Cumulative Proportion  0.91581 0.94525
##                            PC5     PC6
## Standard deviation     0.42797 0.35184
## Proportion of Variance 0.02035 0.01375
## Cumulative Proportion  0.96560 0.97936
##                            PC7    PC8
## Standard deviation     0.32413 0.2419
## Proportion of Variance 0.01167 0.0065
## Cumulative Proportion  0.99103 0.9975
##                            PC9
## Standard deviation     0.14896
## Proportion of Variance 0.00247
## Cumulative Proportion  1.00000
{% endhighlight %}


Como se trabaja con nueve features, los resultados seran iguales, más al ojo del buen observador podrá dar cuenta que en `Cumulative Proportion` en el `PC3` almacena la mayor cantidad de varianza posible, y de ahi en adelante la tasa de acumulación decae de manera exponencial sostenida.


![center](/figs/2020-04-19-PCA_models/unnamed-chunk-3-1.png)

Y validando geométricamente como es el comportamiento de las variables, se observa lo siguiente. 


![center](/figs/2020-04-19-PCA_models/unnamed-chunk-4-1.png)


Todo lo que está sobre el coseno debe leerse como una variable explicativa que almacena gran porpiedad y valor y que por ende puede explicar las variables que se encuentran en contraposición (ejes opuestos). 

Sustentando el PCA es de notar que sobre el coseno $x$ hay tres variables, lo cual es de gran refuerzo para los pasos a seguir.

Una forma de mejorar la interpretación de este PCA es a través de la caracterización de los carros
![center](/figs/2020-04-19-PCA_models/unnamed-chunk-5-1.png)

En este caso los gradientes muestran la capacidad de correlaciones y por ende de explicaciones sobre los carros dada la marca.


![center](/figs/2020-04-19-PCA_models/unnamed-chunk-6-1.png)

Es de notar la la mayor cantidad de información se almacena hasta los `duster 360`

Si se trabajase un feature el resultado sería más valioso. En esta parte tomo el ejemplo usado en Datacamp, puesto que su nivel de interpretación es invaluable.


![center](/figs/2020-04-19-PCA_models/unnamed-chunk-7-1.png)


Se puede apreciar que los carros de origen americano tienen como caracteristícas de altos valores en en cylinders, Displacement y en Weight.


Para verlo de una marena más amena se trabajaría con la siguiente gráfica (sustentar respuesta anterior)


![center](/figs/2020-04-19-PCA_models/unnamed-chunk-8-1.png)
