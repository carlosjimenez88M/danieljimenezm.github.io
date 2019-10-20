---
title: "Redes Bayesianas"
output: html_document
mathjax: "true"
---



El uso de Bayes en temas como Machine Learning , estadística y en aplicaciones de AI son impresionantes y es por ello que este tipo de corriente es fundamental para tener modelos optimos para el que - hacer bajo un foco de negocio o investigación. Puntualmente la corriente del [emprirical bayes](https://en.wikipedia.org/wiki/Empirical_Bayes_method) proporciona una versión de diseño de modelos más apropiados , gracias a los parámetros que define en el proceso inferencial.


## Conceptos previos

* ¿ En qué consiste la teoría Bayesiana ?

Una aproximación que me llama la atención es la siguiente :
    
    + Es la que estudia el verdadero estado de un objeto de estudio en grados de incertidumbre.
  
Otra definición que cala más con un concepto en el mundo real es   
    
    + Es el procedimiento matemático que permite actualizar las probabilidades de los eventos determinados por creencias previas.
    
Dicho lo anterior , los metódos bayesianos se caracterizan por no tener en cuenta las probabilidad como una frecuencia rígida, sino por permitirse mover las distribuciones de las frecuencias (previa  y posterior). Dicho lo anterior la estadística bayesiana tiene las siguientes particularidades:

    + Variación en los parámetros
    + Data flexible 
    + Probabilidad condicionada
    + Credibilidad en los intervalos 
    + Una probabilidad prior (fuerte)
    
Dicho lo anterior , la probabilidad bayesiana tiene el siguiente comportamiento


$$
P(A|B) = \frac{P(B|A) P(A)}{P(B)}
$$

Donde:

i) P(A) = Probabilidad a priori

ii) P(B|A) = Probabilidad de B dada la hipótesis de A

iii) P(A|B) = Probabilidad posterior








Esta formula es indudablemente revolucionaria , por su sencillez y gran capacidad de aplicación. La [teoría bayesiana](https://towardsdatascience.com/bayes-theorem-the-holy-grail-of-data-science-55d93315defb), expresa la probabilidad condicionanda de un evento aleatorio gracias a la probabilidad de las distribuciones de los eventos.


## Redes Bayesianas 

Las redes bayesianas son el conjunto de grafos que representan un conjunto de variables random y sus condiciones. Un ejemplo sería : relaciones probabilisticas entre condiciones macroeconómicas y  crisis económicas.


Otra definición que puede ayudar a interpretar este concepto es la siguiente 

>"Bayesian networks (BNs) are a type of graphical model that encode the conditional probability between different learning variables in a directed acyclic graph." Hamed,(2019)


Dicho lo anterior cuando se desarrollan BNs (Bayesian Networks ) estamos hablando de una técnica del [ML no supervisado ](https://towardsdatascience.com/unsupervised-machine-learning-9329c97d6d9f), la cual es eficiente en el sentido de encontrar estadísticos robustos.


Un ejemplo sería el siguiente (la data está incluida en el paquete [bnlearn](http://www.bnlearn.com/)). "Coronary" es un set de tatos que describe los facortes de riesgo para una trombosis coronaria.

La estructura de los datos es la siguiente 

* Smoking : Si fuma o no !
* Strenuous mental work : Si el trabajo es estresante mentalmenter
* Strenuous physical work: Si el trabajo exige algún nivel de estrés fisico.
* Pressure: Presión {<140,140>}
* Proteins : Radio de beta o alfa lipoproteinas.
* Family : Antecedentes familiares de enfermedades coronarias.


## Un poco de análisis exploratorio







La distribución de las observaciones sobre los que fuman o no es la siguiente

![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-3-1.png)



La Diferencia es mínima entre los fumadores y los no , por lo cual computare una estadística que determine el comportamiento promedio entre si es fumador o no y los efectos sobre  su presión.



|Smoking |Pressure | Total|  perc|
|:-------|:--------|-----:|-----:|
|no      |<140     |   515| 53.59|
|no      |>140     |   446| 46.41|
|yes     |<140     |   539| 61.25|
|yes     |>140     |   341| 38.75|

La proporción indica que los fumadores tienden a tener la presión más baja.


Ahora estudiaré está relación en una comparación con los antecedentes familiares , el estrés laboral y el estrés fisico
![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-5-1.png)

Primeras conclusiones :

* Tiende a fumarse un poco más cuando hay antecedentes familiares, más al diferencia no es relevante;

* Se fuma menos cuando hay estrés mental laboral;

* Se fuma más cuando hay evidencia de estrés fisico.

Quedo con una duda, y es si realmente hay una diferencia o no cuando los individuos tienen antecedentes familiares, por lo cual desarrolllo una prueba de inferencia y los resultados son los siguientes (código abierto)

![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-6-1.png)

<table class="table table-striped" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;"> tstat_lessthan140 </th>
   <th style="text-align:right;"> tstat_morethan140 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 132.5117 </td>
   <td style="text-align:right;"> 45.05263 </td>
  </tr>
</tbody>
</table>

Se calculan los P valores

<table class="table table-striped" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;"> pval_neg140 </th>
   <th style="text-align:right;"> pval_pos140 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0048042 </td>
   <td style="text-align:right;"> 0.0141283 </td>
  </tr>
</tbody>
</table>

La evidencia muestra que no hay evidencia para decir que las personas fuman o no desde los antecedentes familiares.


## Creando la Red Bayesiana 


Lo primero es crear la red , la cual determinará la dependencia entre variables


![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-9-1.png)


El ejericio que intente describir en el paso anterior (exceptuando la parte de inferencia), se puede resumir con la construcción de la red, lo importante de esto es lo que al principio del post argumentaba **estudiar la relación probabilistica entre variables aleatorias**.


Lo que se puede observar de antemano es que hay algunas relaciones que no tienen sentido practico, por lo cual se elimina la relación entre familia con antecedentes y el estrés mental.


![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-10-1.png)

Ahora se calculan las probabilidades condicionales 


{% highlight text %}
## 
##   Parameters of node Proteins (multinomial distribution)
## 
## Conditional probability table:
##  
## , , M..Work = no
## 
##         Smoking
## Proteins        no       yes
##       <3 0.6685824 0.6167763
##       >3 0.3314176 0.3832237
## 
## , , M..Work = yes
## 
##         Smoking
## Proteins        no       yes
##       <3 0.5671982 0.3235294
##       >3 0.4328018 0.6764706
{% endhighlight %}


Se desarrolla un ejercicio de inferencia para determinar de manera correcta los parámetros de está red y los resultados son los siguientes

Protenias presenta una relación con dos variables, pero el sentido practico indica que debe ser por una, en la inferencia se intenta probar que el efecto de que sea menor a tres se debe al hecho de no fumar. El resultado es el siguiente

{% highlight text %}
## [1] 0.6210279
{% endhighlight %}


Pero si se intenta determinar que el efecto de la proteina sea debido a que no fume , cuál es la probabilidad de que sea un no fumador y tener una presión mayor a 140?

{% highlight text %}
## [1] 0.5905383
{% endhighlight %}

La probabilidad es del 65%





## Simulación de datos 

El proceso de simulación se desarrolla a través de muestreo de cada uno de los nodos raíz,  está técnica con las redes Bayesianas, dada la actualización del conocimiento permite que los estadísticos más robustos sean lo más fieles o similares a la data original. Esta técnica es fundamental para el desarrollo de modelos de ML , puntualmente para equilibrar la data o generar sets de entrenamiento.





{% highlight text %}
## The following objects are masked from coronary (pos = 3):
## 
##     Family, M..Work, P..Work, Pressure, Proteins, Smoking
{% endhighlight %}



{% highlight text %}
## The following objects are masked from coronary (pos = 7):
## 
##     Family, M..Work, P..Work, Pressure, Proteins, Smoking
{% endhighlight %}



{% highlight text %}
## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
{% endhighlight %}



{% highlight text %}
## Warning in normalizePath(f2): path[1]="webshot5697c8794b6.png": No such
## file or directory
{% endhighlight %}



{% highlight text %}
## Warning in file(con, "rb"): cannot open file 'webshot5697c8794b6.png': No
## such file or directory
{% endhighlight %}





A través de la simulación bayesiana dada las de pendencias y probabilidad de las ocurrencias se obtiene el siguiente resultado


|Smoking |M..Work |P..Work |Pressure |Proteins |Family |
|:-------|:-------|:-------|:--------|:--------|:------|
|no      |yes     |no      |<140     |<3       |neg    |
|yes     |no      |yes     |>140     |<3       |neg    |
|no      |yes     |no      |<140     |<3       |neg    |
|no      |no      |yes     |>140     |>3       |neg    |
|yes     |no      |yes     |>140     |<3       |neg    |
|no      |yes     |no      |<140     |<3       |neg    |


Se compara la data simulada con respecto a la original

![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-17-1.png)

![center](/figs/2019-10-19-Redes_Bayesianas/unnamed-chunk-18-1.png)



##  Generar un modelo en cada caso

Se generan modelos modelos lineales generalizados para evaluar cada uno de los estadísticos y compararlos entre la data simulada y la original.


{% highlight text %}
## 
## Call:  glm(formula = Pressure ~ ., family = binomial(link = "logit"), 
##     data = coronary)
## 
## Coefficients:
## (Intercept)   Smokingyes   M..Workyes   P..Workyes   Proteins>3  
##    -0.60410     -0.33507      0.39470      0.30931      0.34322  
##   Familypos  
##     0.09737  
## 
## Degrees of Freedom: 1840 Total (i.e. Null);  1835 Residual
## Null Deviance:	    2513 
## Residual Deviance: 2473 	AIC: 2485
{% endhighlight %}

Para la data simulada


{% highlight r %}
glm(Pressure~., data = coronary_sim,family = binomial(link = "logit"))
{% endhighlight %}



{% highlight text %}
## 
## Call:  glm(formula = Pressure ~ ., family = binomial(link = "logit"), 
##     data = coronary_sim)
## 
## Coefficients:
## (Intercept)   Smokingyes   M..Workyes   P..Workyes   Proteins>3  
##    -0.31121     -0.37270      0.41414      0.11857     -0.03745  
##   Familypos  
##    -0.19857  
## 
## Degrees of Freedom: 1840 Total (i.e. Null);  1835 Residual
## Null Deviance:	    2510 
## Residual Deviance: 2476 	AIC: 2488
{% endhighlight %}

La conclusión es que los estadísticos son bastante similares, por lo cual la simulación cumplio el fin buscado!






