---
title: "Representacion de un modelo"
author: "Daniel Jiménez"
date: "10/14/2019"
mathjax: "true"
category: r
tags: [blog]
comments: true
output: html_document
---




>If you want to be a good data scientist, you should spend ~49% of your time developing your statistical intuition (i.e. how to ask good questions of the data), and ~49% of your time on domain knowledge (improving overall understanding of your field). Only ~2% on methods per se. Nate Silver 2019

## Determinantes para la selección de un modelo


El diseño de modelos estadísticos parte de la comprensión de que variables tienen efectos sobre las otras, para asi poder determinar que tanto puede ayudar a ajustar y determinar (*causa - efecto*) sobre el objetivo de estudio.

Dicho lo anterior hay tres vertientes a determinar, para que el objetivo del diseño de los modelos pueda resolverse


* EDA
    + Entender los datos
    + Asociar los datos
    + Visualizar los datos
    
* Selección de variables 
* Validación de los supuestos.

Para realizar este trabajo se usaran dos librerias de R, [Broom](https://cran.r-project.org/web/packages/broom/vignettes/broom.html) la cual se encarga de *resumir la información estadística de los objetos de trabajo*, mientras que [tidyverse](https://www.tidyverse.org/) sirve como paquete compilador de acciones de manipulación de datos orientado a la ingenieria de datos y la aplicación del desarrollo de modelos para ciencia de datos.

Omitere algunos conceptos de carácter técnico, más la documentación necesaria para ello estará atada a hipervinculos sobre las ideas que aquí presento.

## Etapa I : Los Datos


Lo primero para el diseño de los modelos estadísticos es la obtención de los datos , de este paso no mencionare nada, dado que todo depende de la fuente de obtención, un consejo practico, cuando se tienen *Q* alta de datos, lo mejor es trabajar con una de las platarmas de gestión de datos como Bigquery, dado que en el fondo incluye un map reduce, lo cual permite hacer la transformación de datos de la mejor manera posible. Cuando menciono tranformación de datos hago referencia a las operaciones u operaciones matemáticas para darle sentido a los datos.

Paso dos, viene dado por las visualización de datos. En está parte en lo personal, la considero la más importante al tratar de descubir la distribución de los datos o hacer el proceso de inferencia estadística, paso seguido se trabaja con la **organización de datos**: en esta parte se ejecutan con base al descubrimiento de los patrones en los datos para así poder desarrollar insights de negocio o del problema en especifico.


Suponga el siguiente ejemplo: Se desea desarrollar un modelo que permita predecir los valores el alto del sépalo de una planta (se trabajará con la base de datos de *iris*), por lo tanto se intenta describir el comportamiento promedio de las mismas






{% highlight text %}
##     setosa versicolor  virginica 
##      5.006      5.936      6.588
{% endhighlight %}

Notese que tienen comportamientos similares promedios el largo de sépalo entre las especies, si se evalua por la varianza (variabilidad entre los datos), se puede observar lo siguiente



{% highlight text %}
##     setosa versicolor  virginica 
##  0.1242490  0.2664327  0.4043429
{% endhighlight %}

Puede observarse que la especie que menor variación promedio tiene es la setosa y la de mayor volatilidad es la virginica, observese esto descrito en percentiles



|     | Sepal Length|
|:----|------------:|
|0%   |          4.3|
|25%  |          4.8|
|50%  |          5.0|
|75%  |          5.2|
|100% |          5.8|

Mientras que versicolor tiene el siguiente comportamiento


|     | Sepal Length|
|:----|------------:|
|0%   |          4.9|
|25%  |          5.6|
|50%  |          5.9|
|75%  |          6.3|
|100% |          7.0|



Ahora se evalua la correspondencia entre las variables a través de un gráfico


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-168-1.png)

Notese las correlaciones más fuentes entre las variables, este es un buen indicio para el desarrollo de un modelo. Pero par aclarar mejor está idea se usara el paquete [corrr](https://github.com/tidymodels/corrr), para detallar de mejor manera este fit


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-169-1.png)

Las lineas azules indican que son correlaciones directas y fuertes, mientras que las líneas rojas indican una relación inversamente proporcional, a la hora de ver lo anterior de forma matricial el resultado es el siguiente



{% highlight text %}
## 
## Correlation method: 'pearson'
## Missing treated using: 'pairwise.complete.obs'
{% endhighlight %}



{% highlight text %}
##        rowname Petal.Length Petal.Width Sepal.Length Sepal.Width
## 1 Petal.Length                                                  
## 2  Petal.Width          .96                                     
## 3 Sepal.Length          .87         .82                         
## 4  Sepal.Width         -.43        -.37         -.12
{% endhighlight %}


## Encontrando la distribución de los datos


Conocer la distribución de los datos permitirá el desarrollo del proceso de inferencia estadística, con lo cual los supuestos sobre los grupos de los datos pueden aliniarce a las ideas del objeto de estudio. Lo más importante de esto es que si se conoce las distribuciones de probabilidad, por ende se puede conocer las propiedades de los datos.

Usualmente para este tipo de trabajo se suele usar los histogramas. Se presentaran cuatro histogramas, pero me enfocaré solo un uno para presentar el desarrollo del concepto de la distribución de probabilidad.


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-171-1.png)

Para saber a que tipo de distribución corresponde cada una de las variables se suele verificar a través de su forma a que familia corresponde y por ende sus propiedades

![](https://relopezbriega.github.io/images/distribution.png)

En el caso de *Sepal.Width*, se puede decir lo siguiente:

* El comportamiento de la variable tiene la siguiente estructura


{% highlight text %}
##    vars   n mean   sd median trimmed  mad min max range skew kurtosis   se
## X1    1 150 3.06 0.44      3    3.04 0.44   2 4.4   2.4 0.31     0.14 0.04
{% endhighlight %}

* El histograma indica la siguiente forma

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-173-1.png)

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-174-1.png)

Dado los valores descriptivos y la forma de la distribución de probabilidad, se puede suponer que está variable se comporta como una [normal](https://statisticsbyjim.com/basics/normal-distribution/#targetText=The%20normal%20distribution%20is%20a%20probability%20distribution.,will%20fall%20within%20that%20interval.) y [Lognormal](https://es.wikipedia.org/wiki/Distribuci%C3%B3n_log-normal)



Al desarrollar una prueba para determinar que estos supuestos tienen cierta validez se desarrollan los siguentes operaciones

* Suponer una distribución


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-175-1.png)

{% highlight text %}
## summary statistics
## ------
## min:  2   max:  4.4 
## median:  3 
## mean:  3.057333 
## estimated sd:  0.4358663 
## estimated skewness:  0.3189657 
## estimated kurtosis:  3.228249
{% endhighlight %}

La prueba parece indicar que la distribución teórica de la variable tiene posibilidad de ser : i) Normal, ii) Weibull o iii) Lognormal. Para poder hacer más solido este supuesto se trabajará con boots


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-176-1.png)

{% highlight text %}
## summary statistics
## ------
## min:  2   max:  4.4 
## median:  3 
## mean:  3.057333 
## estimated sd:  0.4358663 
## estimated skewness:  0.3189657 
## estimated kurtosis:  3.228249
{% endhighlight %}

Todo parece indicar que es una *log - normal*, más de desarrollaran unas pruebas para ello.




Con la Weibull se encuentra lo siguiente


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-178-1.png)

La distribución teórica parece tener buen ajuste. Mientras la normal tiene el siguiente comportamiento

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-179-1.png)

El ajuste parece adecuado, por último la log-normal tiene la siguiente estructura

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-180-1.png)


Dado que los tres ajusge parecen oportunos, se trabajará con el AIC para determinar con que distribución quedarse.


{% highlight text %}
## $Normal_Aic
## [1] 372.0795
## 
## $Weibull_Aic
## [1] 385.5377
## 
## $LogNormal_Aic
## [1] 367.9995
{% endhighlight %}

Se selecciona el que tenga menor valor en el criterio de Akaike. Por lo tanto la distribución más adecuada es la logNormal.

## Diseño del modelo

Después de determinar la distribución de las variables de los datos, se procede a desarrollar modelos a través de la inferencia que se pudo adquirir en el paso anterior.


Suponga que se desea predecir el valor del largo del sépalo, por lo tanto se genera un modelo sencillo, el cual es el cuarto paso para poder trabajar con la representación de los modelos.



{% highlight text %}
## # A tibble: 4 x 5
##   term         estimate std.error statistic  p.value
##   <chr>           <dbl>     <dbl>     <dbl>    <dbl>
## 1 (Intercept)     1.86     0.251       7.40 9.85e-12
## 2 Sepal.Width     0.651    0.0666      9.77 1.20e-17
## 3 Petal.Length    0.709    0.0567     12.5  7.66e-25
## 4 Petal.Width    -0.556    0.128      -4.36 2.41e- 5
{% endhighlight %}

El comportamiento objetivo del modelo con todas las variables es el siguiente


{% highlight text %}
## # A tibble: 1 x 11
##   r.squared adj.r.squared sigma statistic  p.value    df logLik   AIC   BIC
##       <dbl>         <dbl> <dbl>     <dbl>    <dbl> <int>  <dbl> <dbl> <dbl>
## 1     0.859         0.856 0.315      296. 8.59e-62     4  -37.3  84.6  99.7
## # … with 2 more variables: deviance <dbl>, df.residual <int>
{% endhighlight %}

Con un ajuste del .85, se puede considerar un buen modelo, pero sería más apremiante compararlo con menor número de variables 



{% highlight r %}
fits<-list(
  fit1 <-lm(Sepal.Length ~ Sepal.Width, data = iris),
  fit2 <-lm(Sepal.Length ~ Sepal.Width +Petal.Length, data = iris),
  fit3 <-lm(Sepal.Length ~ Sepal.Width +Petal.Length + Petal.Width , data = iris)
)


gof<-map_df(fits,glance,.id ='model')%>%
  arrange(AIC)

gof
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 12
##   model r.squared adj.r.squared sigma statistic  p.value    df logLik   AIC
##   <chr>     <dbl>         <dbl> <dbl>     <dbl>    <dbl> <int>  <dbl> <dbl>
## 1 3        0.859        0.856   0.315    296.   8.59e-62     4  -37.3  84.6
## 2 2        0.840        0.838   0.333    386.   2.93e-59     3  -46.5 101. 
## 3 1        0.0138       0.00716 0.825      2.07 1.52e- 1     2 -183.  372. 
## # … with 3 more variables: BIC <dbl>, deviance <dbl>, df.residual <int>
{% endhighlight %}

Notesé que el modelo tres que tiene mayor número de variables explicativas es que el mejor ajuste da a un modelo

Ahora se estudia el comportamiento del residuo de las variables y el resultado es el siguiente
![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-185-1.png)

Al evaluar por inferencia estádistica los valores , se encuentran desde una perspectiva lo siguiente

{% highlight text %}
## Skim summary statistics
##  n obs: 150 
##  n variables: 4 
## 
## ── Variable type:numeric ─────────────────────────────────────────────────
##      variable missing complete   n mean   sd  p0 p25  p50 p75 p100
##  Petal.Length       0      150 150 3.76 1.77 1   1.6 4.35 5.1  6.9
##   Petal.Width       0      150 150 1.2  0.76 0.1 0.3 1.3  1.8  2.5
##  Sepal.Length       0      150 150 5.84 0.83 4.3 5.1 5.8  6.4  7.9
##   Sepal.Width       0      150 150 3.06 0.44 2   2.8 3    3.3  4.4
##      hist
##  ▇▁▁▂▅▅▃▁
##  ▇▁▁▅▃▃▂▂
##  ▂▇▅▇▆▅▂▂
##  ▁▂▅▇▃▂▁▁
{% endhighlight %}

Por lo cual la tabla de regresión del modelo multiple es


{% highlight text %}
## # A tibble: 4 x 7
##   term         estimate std_error statistic p_value lower_ci upper_ci
##   <chr>           <dbl>     <dbl>     <dbl>   <dbl>    <dbl>    <dbl>
## 1 intercept       1.86      0.251      7.40       0    1.36     2.35 
## 2 Sepal_Width     0.651     0.067      9.76       0    0.519    0.783
## 3 Petal_Length    0.709     0.057     12.5        0    0.597    0.821
## 4 Petal_Width    -0.556     0.128     -4.36       0   -0.809   -0.304
{% endhighlight %}

Por lo cual el modelo será

$$
y=1.856+0.651_{Sepal_Width}+0.709_{Petal_Length}-0.556_{Petal_Width}
$$




Y su comportamiento será (a manera desagregada)

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-188-1.png)

Y en general


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-189-1.png)


Por lo cual los valores observados y los ajustados se repreentaran en la siguiente tabla


{% highlight text %}
## # A tibble: 150 x 7
##       ID Sepal_Length Sepal_Width Petal_Length Petal_Width Sepal_Length_hat
##    <int>        <dbl>       <dbl>        <dbl>       <dbl>            <dbl>
##  1     1          5.1         3.5          1.4         0.2             5.01
##  2     2          4.9         3            1.4         0.2             4.69
##  3     3          4.7         3.2          1.3         0.2             4.75
##  4     4          4.6         3.1          1.5         0.2             4.83
##  5     5          5           3.6          1.4         0.2             5.08
##  6     6          5.4         3.9          1.7         0.4             5.38
##  7     7          4.6         3.4          1.4         0.3             4.89
##  8     8          5           3.4          1.5         0.2             5.02
##  9     9          4.4         2.9          1.4         0.2             4.62
## 10    10          4.9         3.1          1.5         0.1             4.88
## # … with 140 more rows, and 1 more variable: residual <dbl>
{% endhighlight %}



## Generalidades sobre el modelo

La suma de los residuos al cuadrado sirve para saber que tan desviada está un modelo sobre su promedio


{% highlight text %}
## # A tibble: 1 x 1
##   sum_sq_residuals
##              <dbl>
## 1             14.4
{% endhighlight %}


El anterior valor permite expresar la variación total de $Y$ en este caso *Sepal.Length*, por lo cual la variación atribuida al error es de 14.44.


## Computando el R ajustado

Recuerde que 

$$
R^2=1-\frac{Var(Residuals)}{Var(y)}
$$

El R^2 sirve para medir el ajuste del modelo, al calcularlo se encuentran los siguientes resultados


{% highlight text %}
## # A tibble: 1 x 1
##   r_squared
##       <dbl>
## 1     0.859
{% endhighlight %}


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-193-1.png)


Ahora  se calculará el error cuadrático medio sirve para calcular el error predictivo.



{% highlight text %}
## # A tibble: 1 x 2
##      mse  rmse
##    <dbl> <dbl>
## 1 0.0963 0.310
{% endhighlight %}

Por último ya se sabe de cuanto es el error promedio que pueden tener las predicciones con un ajuste del 0.86



## Boostraping

Para la técnica de [boostrap](https://machinelearningmastery.com/a-gentle-introduction-to-the-bootstrap-method/#targetText=The%20bootstrap%20method%20is%20a,the%20mean%20or%20standard%20deviation.&targetText=That%20when%20using%20the%20bootstrap,and%20the%20number%20of%20repeats.) se suele usar interacciones que ajusten los valores gracias a los valores obtenidos en las bodades de ajustes

|model | r.squared| adj.r.squared|     sigma|  statistic|   p.value| df|     logLik|       AIC|      BIC|  deviance| df.residual|
|:-----|---------:|-------------:|---------:|----------:|---------:|--:|----------:|---------:|--------:|---------:|-----------:|
|3     | 0.8586117|     0.8557065| 0.3145491| 295.539138| 0.0000000|  4|  -37.32136|  84.64272|  99.6959|  14.44540|         146|
|2     | 0.8401778|     0.8380034| 0.3332867| 386.386150| 0.0000000|  3|  -46.51275| 101.02550| 113.0680|  16.32876|         147|
|1     | 0.0138227|     0.0071593| 0.8250966|   2.074427| 0.1518983|  2| -182.99584| 371.99167| 381.0236| 100.75610|         148|







Inspeccionado los valores residuales de las variables, se obtiene el nivel de dispersión de los datos y con está técnica se puede seleccionar la variable de predicción si también se desea conservar el nivel confiabilidad y certidumbre sobre los datos.



![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-196-1.png)



Conjugando la relación de los datos más parejo , se encuentra lo siguiente


![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-197-1.png)

Al considerar el modelo con la siguiente estructura


$$
\mbox{Sepal_Length}=\frac{k}{\mbox{Petal_width}}+b+e \sim LN(mean,sd)
$$
Donde K y b vienen por bootstrap, y por lo cual los calculos dan el siguiente resultado (sample head)


{% highlight text %}
## # Bootstrap sampling 
## # A tibble: 100 x 2
##    splits           id          
##    <list>           <chr>       
##  1 <split [150/58]> Bootstrap001
##  2 <split [150/61]> Bootstrap002
##  3 <split [150/55]> Bootstrap003
##  4 <split [150/53]> Bootstrap004
##  5 <split [150/52]> Bootstrap005
##  6 <split [150/58]> Bootstrap006
##  7 <split [150/55]> Bootstrap007
##  8 <split [150/54]> Bootstrap008
##  9 <split [150/59]> Bootstrap009
## 10 <split [150/52]> Bootstrap010
## # … with 90 more rows
{% endhighlight %}


{% highlight text %}
## The following objects are masked from iris2 (pos = 5):
## 
##     Petal_Length, Petal_Width, Sepal_Length, Sepal_Width, Species
{% endhighlight %}



{% highlight text %}
## The following objects are masked from iris2 (pos = 12):
## 
##     Petal_Length, Petal_Width, Sepal_Length, Sepal_Width, Species
{% endhighlight %}



{% highlight text %}
## # A tibble: 6 x 6
##   id           term  estimate std.error statistic  p.value
##   <chr>        <chr>    <dbl>     <dbl>     <dbl>    <dbl>
## 1 Bootstrap001 k       -26.6      1.15      -23.2 4.53e-51
## 2 Bootstrap001 b         5.80     0.204      28.5 6.45e-62
## 3 Bootstrap002 k       -25.3      1.48      -17.1 5.43e-37
## 4 Bootstrap002 b         5.59     0.261      21.4 3.12e-47
## 5 Bootstrap003 k       -26.0      1.31      -19.8 2.01e-43
## 6 Bootstrap003 b         5.68     0.230      24.6 2.96e-54
{% endhighlight %}


Y la distribución de probabilidad de k y b dá el siguiente resultado


{% highlight text %}
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
{% endhighlight %}

![center](/figs/2019-10-14-Representacion_Modelos/unnamed-chunk-200-1.png)

