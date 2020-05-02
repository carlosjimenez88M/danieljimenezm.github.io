---
title: "Predicciones"
output: html_document
mathjax: "true"
---






## Introducción 

En el presente post introducire el concepto de **forecasting** (pronósticos) y usare herramientas de análisis exploratorio de datos para contextualizar los alcances de las proyecciones y como es el diseño de las mismas.


Lo interesante de este tipo de análisis es poder llevarlo a la practica desde el sustento teórico fuerte, por lo cual hablaré de varios conceptos necesarios y haré algún tipo de recomendaciones de textos bases.

Por otra parte el gran objetivo de está entrada es poder desarrollar un análisis y pronóstico sobre la situación económica actual de mi país : Colombia, pero para ello no solo haré uso de herramientas estadísticas, sino de la investigación cuantitativa e historía política reciente, para así poder construir un marco adecuado en mis argumentos, intentando alejar cualquier adjetivo político. Dicha entrada se hará en un post nuevo 



### Seríes de tiempo

Una definición que me encanta de las series de tiempo la da el profesor [Norman Giraldo](http://www.medellin.unal.edu.co/~ndgirald/) y dice :

> Una serie de tiempo es una sucesión de variables aleatorias ordenadas de acuerdo a una unidad de tiempo $Y_1,...,Y_t$

Mientras que el profesor [David Matteson](https://stat.cornell.edu/people/faculty/david-s-matteson), la articula de la siguiente manera :

> Time series : A sequence of data in chronological order, [...] Data is commonly recorded sequentially, over time


Para enmarcar estas definiciones trabajaré con la base de datos de [empleo y desempleo](http://www.banrep.gov.co/es/tasas-empleo-y-desempleo) del Banco de la República




|Año  | Tasa de desempleo promedio|
|:----|--------------------------:|
|2019 |                  11.428691|
|2018 |                   9.681340|
|2017 |                   9.378039|
|2016 |                   9.223316|
|2015 |                   8.928725|
|2014 |                   9.108906|
|2013 |                   9.645011|


La anterior información obtendría más sentido si se gráfica y desde ahí se empiezan a formular las primeras hipótesis.


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-3-1.png)

Lo primero que se puede apreciar es un aumento desde el 2015 del desempleo , llegando a explotar, presentando un salto importante en el último periodo, más hay que recordar que para el 2019 solo se analiza hasta el mes de Abril.

#### Frecuencia de muestreo



Para enteder mejor el objeto con el que estoy trabajando, se desarrolla una transformación, se usa el comando ts(Time Series), con el argumento start=2013, que corresponde el año en que inicia el análisis.


{% highlight r %}
ts(TD$Tasa_desprom, start= 2013, frequency = 1)->serie_de_tiempo
serie_de_tiempo  
{% endhighlight %}



{% highlight text %}
## Time Series:
## Start = 2013 
## End = 2019 
## Frequency = 1 
## [1]  9.645011  9.108906  8.928725  9.223316  9.378039  9.681340 11.428692
{% endhighlight %}



{% highlight r %}
plot(serie_de_tiempo, main='Serie de tiempo desempleo 2013-2019', type='b')
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-5-1.png)


La tendencia parece ser clara, pero sería oportuno modelar la varianza, para tener claridad sobre este proceso:


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-6-1.png)

La evidencia es irrefutable , hay un claro crecimiento en la variable desempleo para lo que va corrido del 2019, más esto solo fue una comprobación a través de la varianza, herramienta muy útil si se trabajase con mayor cantidad de datos, por ello se ampliará el período de estudio.



|Año  | Promedio del desempleo| Varianza del desempleo|
|:----|----------------------:|----------------------:|
|2001 |                  14.98|                   1.25|
|2002 |                  15.56|                   0.95|
|2003 |                  14.10|                   1.59|
|2004 |                  13.64|                   2.35|
|2005 |                  11.81|                   1.65|
|2006 |                  12.03|                   0.77|
|2007 |                  11.20|                   1.57|
|2008 |                  11.27|                   0.61|
|2009 |                  12.03|                   0.72|
|2010 |                  11.78|                   1.43|
|2011 |                  10.84|                   1.92|
|2012 |                  10.38|                   1.11|
|2013 |                   9.64|                   1.65|
|2014 |                   9.11|                   1.02|
|2015 |                   8.93|                   0.78|
|2016 |                   9.22|                   1.27|
|2017 |                   9.38|                   0.91|
|2018 |                   9.68|                   0.69|
|2019 |                  11.43|                   1.19|

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-8-1.png)

No es necesario transformar la serie de tiempo, pero si diferenciarla para entender este comportamiento (eliminar la tendencia) 


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-9-1.png)




### Ruido Blanco

Usare una estrategía de la pedagogía para explicar el siguiente concepto. Una serie de tiempo es considerada **ruido blanco** si cumple las siguientes condiciones 

1) $E(\varepsilon _t)=0$ Promedio es cero
2) $Var(\varepsilon_t)\equiv \sigma^2$ Varianza constante
3) $\forall \not= 0, Cov(\varepsilon_t,e_{t+k})\equiv 0$ Incorrelacionada

Lo anterior quiere decir que existen valores a dos ó más tiempos diferentes que no estan correlacionados.

Con algo de matemáticas más especificas el anterior concepto se puede definir de la siguiente forma:

Las series de tiempo están compuestas por dos partes: Los datos explicados por el pasado y la parte impredecible

$$
Y_t=f(Y_{t-1},Y_{t-2},...,Y_{1})+a_t
$$
Donde $a_t$ es la parte que no se puede predecir y es a lo que se le denomina *Ruido Blanco*, gráficamente, su comportamiento es el siguiente


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-10-1.png)

y su gráfico de correlación muestra que no hay ningún coeficiente de correlación significativo, por ende se puede suponer que los datos son independientes

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-11-1.png)

Solo para usar una última opción de afirmación se usa una prueba de hipótesis para comprobar el comportamiento de la seria como Ruido Blanco



{% highlight text %}
## 
## 	Box-Pierce test
## 
## data:  ruido_blanco
## X-squared = 0.68302, df = 1, p-value = 0.4086
{% endhighlight %}

Dado que p-value es mayor que alfa (0.05) entonces se afirma que está variable es ruido blanco


Ahor aun ruido es débil en términos de estacionalidad si :

$$
\gamma(0)=\sigma^2
$$

y

$$
\gamma(h)= 0 \mbox{ si } h \not= 0
$$
Entonces

$$
p(0)=1
$$

Donde

$$
p(h)=0 \mbox{ si } h \not= 0.
$$


Para el ejemplo de la tasa de desempleo (aunque no aplica), se comprueba si es un Ruido blanco a través del promedio y una prueba de hipótesis

El promedio es

{% highlight text %}
## [1] 11.42088
{% endhighlight %}

Y según la Prueba de Hipótesis 


{% highlight text %}
## 
## 	Box-Pierce test
## 
## data:  TD$Tasa_desprom
## X-squared = 12.837, df = 1, p-value = 0.0003398
{% endhighlight %}
Dado que alfa(0.05) es mayor que el P-vale, se acepta que **NO ES UN RUIDO BLANCO**

EL correlograma muestra que si hay una dependencia entre los tiempos y los proceso.
![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-15-1.png)



Como ejercicio para construir conceptos fuertes sobre el ruido, dejo un código abierto donde simulo Ruido Blanco a través de modelos ARIMA



{% highlight r %}
Ruido<-arima.sim(model = list(order=c(0,0,0)), n=100)
Ruido%>%
  head(10)%>%
  cbind()%>%
  kable(caption = 'Simulación de Ruido')
{% endhighlight %}



|          x|
|----------:|
| -1.2053334|
|  0.3014667|
| -1.5391452|
|  0.6353707|
|  0.7029518|
| -1.9058829|
|  0.9389214|
| -0.2244921|
| -0.6738168|
|  0.4457874|


Comprobación


{% highlight r %}
mean(Ruido) ## Está al rededor de cero
{% endhighlight %}



{% highlight text %}
## [1] -0.08420198
{% endhighlight %}

Prueba de hipótesis

{% highlight r %}
Box.test(Ruido)
{% endhighlight %}



{% highlight text %}
## 
## 	Box-Pierce test
## 
## data:  Ruido
## X-squared = 1.4105, df = 1, p-value = 0.235
{% endhighlight %}
P-value mayor a alfa, es ruido blanco, por último el análsis gráfico



{% highlight r %}
ts.plot(Ruido, main='Simulación del ruido', col='red')
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-19-1.png)


Otra forma de simular sería


{% highlight r %}
Ruido_2<-arima.sim(model=list(order=c(0,0,0)),
                   n=500,
                   mean=11,
                   sd=5)
ts.plot(Ruido_2)
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-20-1.png)

Y el estimado a través del Arima sería


{% highlight text %}
## 
## Call:
## arima(x = Ruido_2, order = c(0, 0, 0))
## 
## Coefficients:
##       intercept
##         11.1716
## s.e.     0.2133
## 
## sigma^2 estimated as 22.74:  log likelihood = -1490.48,  aic = 2984.96
{% endhighlight %}


### Caminata aleatoria 


Las caminatas aleatorias son el ejemplo de procesos no estacionarios , por lo tanto no tienen un promedio o varianza especifica. Dicho de otra manera una caminata aleatoria es el determinante del futuro más un cambio impredecible.

$$
E[y_t[y_{t_1},y_{t_2}]]=y_{t_1} \mbox{ de la original que es } y_t=y_{t_1}+\varepsilon_t 
$$

Por lo tanto la Caminata aleatoria es una serie de tiempo que no capta estacionalidad ni tendencia, por lo tanto solo se encuentra el error $(\varepsilon_t)$

Este tipo de series se clasifican de la siguiente manera

* No estacionarias: Son series en las cuales la tendencia cambia con el tiempo. Los cambios en el promedio o en la varianza se notan a largo plazo, dado que la serie no se encuentra fluctuando al rededor de un valor constante.

* No estacionarias en el promedio: El cambio en el promedio implica tendencia

* No estacionaria en varianza: La dispersión de los datos no es constante en el tiempo.No hay un patrón especifico.

* Estacionaria: La serie es estable a lo largo del tiempo, por lo tanto el promedio y la varianza son constantes en el tiempo

* Estacionaria en el promedio: La serie no tiene tendencia

Dicho lo anterior algunas caracteristica de las caminatas aleatorias son:

* No hay promedio o varianza especifica
* Fuerte dependencia al tiempo
* Depende del cambio o incremento del Ruido Blanco

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-22-1.png)



Una forma de evaluar las caminatas aleatorias y determinar a que grupo pertenencen es através del análisis gráfico del modelo (código abierto)



{% highlight r %}
caminata<- arima.sim(model = list(order = c(0, 1, 0)), n = 100)
caminata_diff <- diff(caminata)
modelo<-arima(caminata_diff,order = c(0,0,0))
int_modelo <-modelo$coef
ts.plot(caminata)
abline(0,int_modelo)
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-23-1.png)

## Procesos estacionarios


Una definición sencilla de los procesos estacionarios es: *la variación periódica y pronosticable de una seria de tiempo*. La estacionaloidad de los modelos tiende a ser parsimoniosa y por ello se puede observar cierta estabilidad bajo la variable tiempo, por lo tanto este tipo de comportamiento puede fluctuar en secciones al rededor de unos datos y tener comportamientos semi-repicables en otros.

Cuando se trabaja con procesos plenamente estacionarios, se puede observar que para toda $x,y$

$$
(Y_1,...,Y_n) \mbox{ y }(Y_{1+m},....,Y_{n+m}) \mbox{ donde tienen la misma distribución}
$$

Mientras que cuando la estacionalidad es debíl, notese que adquiere un promedio, varianza y covarianza sin cambios en espacios de tiempo. Por lo tanto su comportamiento sería:

1) $E(Y_t)=\mu$ la cual es constante para todo $t$
2) $Var(Y_t)=\sigma^2 \forall \mathbf{R}^{+}_{>0}$ para toda $t$
3) $Cov(Y_t,Y_s)=\gamma(|t-s|)$ para todo $t,s$ para algunas funciones $\gamma(h)$

Por lo tanto la estacionalidad debíl hace referencia a la covarianza de la estacionalidad, donde el promedio y la varianza no tiene cambios con el tiempo, y la covarianza de dos observaciones depende se los lags (distancia de los tiempos entre las observaciones).


Matemáticamente, lo anterior quiere decir que 

$$
Y_t \mbox{ & } Y_s \mbox{ es constante } \forall \mbox{ } |t-s|=h
$$

Un ejemplo sería la inflación o el IPC, casos que evaluaran en el siguiente post.


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-24-1.png)![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-24-2.png)

{% highlight text %}
## Warning in log(returns): NaNs produced
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-24-3.png)




### Analísis Correlacional y de varianza

Uno de los aspectos más importantes y al cual deseo dedicarle especial atención es al de las correlaciones y la covarianza, empezare definiendo que es un covarianza como la variación conjugada entre dos variables respecto al promedio.

Lo anterior quiere decir que la *covarianza* mide el grado de relación lineal entre dos variables

$$
cov_{x,y}=\frac{\sum^n_{1}(x_{i}-\bar{x})(y_i-\bar{y})}{n}
$$
Para llegar a una mejor definición trabajaré con acciones de Apple y el CFD (índice de divisa del dolar), y una segunda relación con las acciones de Nike


{% highlight text %}
## Parsed with column specification:
## cols(
##   Fecha = col_character(),
##   Último = col_number(),
##   Apertura = col_number(),
##   Máximo = col_number(),
##   Mínimo = col_number(),
##   Vol. = col_character(),
##   `% var.` = col_character()
## )
## Parsed with column specification:
## cols(
##   Fecha = col_character(),
##   Último = col_number(),
##   Apertura = col_number(),
##   Máximo = col_number(),
##   Mínimo = col_number(),
##   Vol. = col_character(),
##   `% var.` = col_character()
## )
## Parsed with column specification:
## cols(
##   Fecha = col_character(),
##   Último = col_number(),
##   Apertura = col_number(),
##   Máximo = col_number(),
##   Mínimo = col_number(),
##   Vol. = col_character(),
##   `% var.` = col_character()
## )
{% endhighlight %}


A continuación se presentan los datos de las acciones


|Fecha      | Último| Apertura| Máximo| Mínimo|Vol.   |% var. |
|:----------|------:|--------:|------:|------:|:------|:------|
|2019-06-14 |  19168|    19107|  19212|  19035|5,74M  |-1,27% |
|2019-06-13 |  19415|    19488|  19682|  19371|21,67M |-0,02% |
|2019-06-12 |  19419|    19395|  19597|  19338|18,25M |-0,32% |
|2019-06-11 |  19481|    19486|  19600|  19360|26,93M |1,16%  |
|2019-06-10 |  19258|    19181|  19537|  19162|26,22M |1,28%  |
|2019-06-07 |  19015|    18651|  19192|  18577|30,68M |2,66%  |
|2019-06-06 |  18522|    18308|  18547|  18215|22,53M |1,47%  |
|2019-06-05 |  18254|    18428|  18499|  18114|29,77M |1,61%  |
|2019-06-04 |  17964|    17544|  17983|  17452|30,97M |3,66%  |
|2019-06-03 |  17330|    17560|  17792|  17027|40,40M |-1,01% |


|Fecha      | Último| Apertura| Máximo| Mínimo|Vol.   |% var. |
|:----------|------:|--------:|------:|------:|:------|:------|
|2019-06-14 |   8363|     8341|   8387|   8310|1,18M  |0,02%  |
|2019-06-13 |   8361|     8315|   8392|   8305|3,36M  |1,19%  |
|2019-06-12 |   8263|     8348|   8402|   8252|4,03M  |-0,76% |
|2019-06-11 |   8326|     8365|   8433|   8312|3,94M  |0,82%  |
|2019-06-10 |   8258|     8375|   8420|   8245|4,42M  |-1,00% |
|2019-06-07 |   8341|     8309|   8368|   8281|3,89M  |1,16%  |
|2019-06-06 |   8245|     8272|   8306|   8208|4,95M  |-0,33% |
|2019-06-05 |   8272|     8229|   8290|   8193|8,17M  |1,35%  |
|2019-06-04 |   8162|     7930|   8165|   7878|7,53M  |4,69%  |
|2019-06-03 |   7796|     7724|   7858|   7708|11,67M |1,06%  |



|Fecha      | Último| Apertura| Máximo| Mínimo|Vol.   |% var. |
|:----------|------:|--------:|------:|------:|:------|:------|
|2019-06-14 |  97338|    97012|  97377|  96938|-      |0,35%  |
|2019-06-13 |  96999|    96940|  97075|  96860|-      |0,03%  |
|2019-06-12 |  96970|    96670|  96990|  96545|24,48K |0,34%  |
|2019-06-11 |  96645|    96700|  96860|  96605|19,95K |-0,07% |
|2019-06-10 |  96711|    96580|  96895|  96575|24,30K |0,23%  |
|2019-06-07 |  96490|    96965|  97130|  96405|29,82K |-0,52% |
|2019-06-06 |  96997|    97265|  97390|  96720|27,67K |-0,26% |
|2019-06-05 |  97251|    97055|  97305|  96655|25,32K |0,26%  |
|2019-06-04 |  96999|    97135|  97275|  96900|25,60K |-0,06% |
|2019-06-03 |  97060|    97700|  97720|  97015|29,61K |-0,62% |

Se trabajará con los valores en la columna *Último*



{% highlight r %}
mean(CDF$Último) 
{% endhighlight %}



{% highlight text %}
## [1] 96946
{% endhighlight %}



{% highlight r %}
sd(CDF$Último)
{% endhighlight %}



{% highlight text %}
## [1] 262.9411
{% endhighlight %}



{% highlight r %}
mean(Nike$Último)
{% endhighlight %}



{% highlight text %}
## [1] 8238.7
{% endhighlight %}



{% highlight r %}
sd(Nike$Último)
{% endhighlight %}



{% highlight text %}
## [1] 167.4887
{% endhighlight %}



{% highlight r %}
par(mfrow=c(1,2))
plot(CDF$Último,type = 'l', col='grey', ylab = 'Último', main = 'CDF')
plot(Nike$Último, col='red',type = 'l',ylab = 'Último', main = 'Nike')
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-29-1.png)




Ahora se explora la vocarianza entre las dos variables, y se evidencia una correlación negativa -7302.8888889, quiere decir que al aumentar el CDF disminuye el valor de las acciones de Nike, si se mira desde la correlación lineal, se determina el valor -0.1658253 , la relación no es fuerte, pero tiene efectos


Para el caso de Apple y CDF se encuentra que la covarianza de `rcov(Apple$Último, CDF$Último)`, lo que indica que es un poco más fuerte la relación la cual se establece en -0.3520718


Pero para poder abstraer mejor está información lo mejor es trabajar con la Autocovarianza y la Autocorrelación. La autocorrelación , en el siguiente ejemplo de código se muestran las correlaciones en dos versiones Hoy versus Ayer y Hoy versus dos días atrás


{% highlight r %}
Nike$Último->NK
cor(NK[-9],CDF$Último[-1]) ## Nike hoy vs CDF Ayer
{% endhighlight %}



{% highlight text %}
## [1] -0.1960546
{% endhighlight %}



{% highlight r %}
cor(Nike$Último[-c(8:9)],CDF$Último[-c(1:2)]) ## Nike hoy vs CDF Dos días atras
{% endhighlight %}



{% highlight text %}
## [1] -0.2885084
{% endhighlight %}



Para entender mejor este aspecto se ddesarrolla primero el acf con lag de un día y después de dos



{% highlight r %}
acf(Nike$Último, lag.max = 1, plot = F)
{% endhighlight %}



{% highlight text %}
## 
## Autocorrelations of series 'Nike$Último', by lag
## 
##     0     1 
## 1.000 0.223
{% endhighlight %}


{% highlight r %}
acf(Nike$Último, lag.max = 2, plot = F)
{% endhighlight %}



{% highlight text %}
## 
## Autocorrelations of series 'Nike$Último', by lag
## 
##     0     1     2 
## 1.000 0.223 0.045
{% endhighlight %}
Y  uno general donde se evidencia el total en lags

{% highlight r %}
acf(Nike$Último, plot = F)
{% endhighlight %}



{% highlight text %}
## 
## Autocorrelations of series 'Nike$Último', by lag
## 
##      0      1      2      3      4      5      6      7      8      9 
##  1.000  0.223  0.045  0.025 -0.114 -0.004 -0.141 -0.063 -0.252 -0.218
{% endhighlight %}


{% highlight r %}
acf(Nike$Último, plot = T)
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-34-1.png)

Parece ser que la correlación presenta aspectos de ser Ruido o no tener correlación con el tiempo.


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-35-1.png)




![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-36-1.png)



Ahora si definire lo anterior, la función de autocorrelación permite evaluar una setie de tiempo con su pasado, lo que quiere decir que representa la relación de los datos con respecto a las observaciones y momento en que se dan.

## Modelos autoregresivos 

Una definición que en lo personal me encanta es la siguiente: Se dice que $y_n,n\in\mathbf{Z}$ es autoregresiva de promedio cero si 

$$
y_n \equiv \lambda_1Y_{n-1}+\lambda_2Y_{n-2}+...+\lambda_mY_{n-m}+e_n
$$
Donde usando el rezado L

$$
\lambda_{\lambda}(L)(Y_n)=e_n
$$


con 
$$
\lambda_{\lambda}(z)=1-\lambda_1z-\lambda_2z^2-..--\lambda_pz^p
$$
Lo que describe que es un polinomio autoregresivo.

Lo anterior se somete a los supuestos en que  lo Autoregresivo cuando las raíces de la ecuación 

$$
|z_i|>1
$$

Por lo tanto las condiciones de un proceso autoregresivo son :

1) $E(Y_t)=0$
2) $\sum_{j=1}^{p} \lambda<1$

Por lo tanto y basandonos en el ejemplo anterior un proceso Autoregresivo sería

$$
Hoy=Constante+Pendiente+Ayer*Ruido
$$

Donde el promedio será

$$
(Hoy-promedio)=Tendencia*(Ayer-Promedio)+Ruido
$$

Lo anterior matemáticamente se escribe como

$$
Y_t-\mu=\oslash (Y_{t-1}-\mu)+e_{t}
$$
Donde

* $\mu$ es el promedio de los procesos $Y_t$
* $\phi=0$ , entonces $Y_t=\mu+e_t$, por lo tanto $Y_t$ es Ruido
* $\phi\not=0$, por lo tanto las observaciones dependen de $e_t$, para todo $Y_t$, por lo cuak es autocorrelacionada
* Valores positivos de $\phi$ generan correlaciones fuertes
* Los valores negativos de $\phi$ los resultados pueden ser oscilatorios

Describiendo lo anterior de manera más formal , el promedio se comporta de la siguiente manera


$$
E(Y_t)=\mu
$$

Mientras la varianza es

$$
Var(Y_t)=\sigma^2_y=\frac{\sigma^{2}_{e}}{1-\phi}
$$
Y por último y la más importante de todas, la Autocorrelación sería

$$
Corr(Y_t,Y_{t-h})=p(h)=\phi^{|h|} \forall \mbox{ h }
$$

Si $\mu=0$ y $\phi=1$, entonces $Y_t=Y_{t-1}+e_t$ es una caminata aleatoria y $Y_t$ no es estacionaria.

En los siguientes ejemplos gráficos se presentaran AR con .7,.9 y.2, recuerde que la interpretacuón de la función autoregresiva es similar a la de la regresión lineal


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-37-1.png)


Y ahora si viene el argumento rector de este post **PRONOSTICOS**, en los siguientes gráficos se presentaran los gráficos de series de tiempo y acf (Autocorrelación) en donde se evidencia una fuerte tendencia entre el tiempo y la tasa de desempleo, por lo cual y a manera de economista podría decir que hay evidencias que la tasa de desempleo responde a un ciclo político.

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-38-1.png)

A continuación desarrollare un modelo autoregresivo del desempleo a través de la siguiente ecuación

$$
(Desempleo_{2019}-promedio)=Tendencia*(Desempleo_{2018}-promedio)+Ruido
$$
Lo que sería igual a 

$$
Y_t-\mu=\phi (Y_{t-1}-\mu)+e_t
$$
Por lo tanto 


{% highlight text %}
## 
## Call:
## arima(x = Tasa_desempleo, order = c(1, 0, 0))
## 
## Coefficients:
##          ar1  intercept
##       0.9198    12.3964
## s.e.  0.0743     1.6404
## 
## sigma^2 estimated as 0.6727:  log likelihood = -24.13,  aic = 54.26
{% endhighlight %}

Recordando que ar1=$\hat{\phi}$, el intercepto es =$\hat{\mu}$ y que sigma^2 es $\sigma^2_e$

Ahora se desarrolla la predicción para un periodo de tiempo




El pronostico para el siguiente periodo es de 11.5075352% , ahora haré 3 predicciones sobre la tasa de desempleo



|     Pred|
|--------:|
| 11.50754|
| 11.57885|
| 11.64444|









![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-42-1.png)


## Promedio móvil

El promedio móvil se define por las constantes en $\mu$ y $\theta$

$$
Y_t=\mu+e_t+\theta_{et-1}
$$


Por lo tanto

* $\mu$ es el promedio de los procesos $Y_t$

* $\theta=0$ donde $Y_{t}=\mu+e_{t}$ por lo tanto $Y_t$ donde es Ruido Blanco

* $\theta \not= 0$ entonces las observaciones de $Y_t$ dependen de $e_t$ y $e_{t-1}$, el proceso es autocorrelacionado

* $\theta \not= 0$ entonces $e_{t-1}$ depende de $Y_t$ hacia el futuro.

* $\theta$ es determinante del impacto

* Los valores grandes de $|\theta|$ tienen efectos de proporciones amplias.



El comportamiento de la promedio movil es el siguiente

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-43-1.png)

Y su función de autocorrelación se comporta de la siguiente manera


![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-44-1.png)

Ahora se evaluara el cambio en el desempleo a través de promedio movil



{% highlight r %}
Tasa_desempleo_dif<-diff(Tasa_desempleo)
par(mfrow=c(1,2))
ts.plot(Tasa_desempleo)
ts.plot(Tasa_desempleo_dif)
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-45-1.png)

Ahora se evalua la autocorrelación

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-46-1.png)

Nueva evidencia a la correspondencia de un evento externo al entorno normal  para explicar el comportamiento, ahora se desarrolla un modelo para entender el comportamiento del desempleo y su proyección a través del promedio movil



{% highlight text %}
## 
## Call:
## arima(x = Tasa_desempleo_dif, order = c(0, 0, 1))
## 
## Coefficients:
##          ma1  intercept
##       0.0526    -0.1892
## s.e.  0.2182     0.2041
## 
## sigma^2 estimated as 0.6624:  log likelihood = -21.84,  aic = 49.67
{% endhighlight %}

se estiman los valores residuales

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-48-1.png)

La relación es particular, al parecer, al desarrollar la predicción desde este punto se encuentra lo siguiente:


{% highlight text %}
## $pred
## Time Series:
## Start = 2020 
## End = 2022 
## Frequency = 1 
## [1] -0.08852191 -0.18915120 -0.18915120
## 
## $se
## Time Series:
## Start = 2020 
## End = 2022 
## Frequency = 1 
## [1] 0.8138674 0.8149922 0.8149922
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-50-1.png)

A nivel de tendencia parece tener mejor sentido.




{% highlight text %}
## [1] 11.89386
{% endhighlight %}

![center](/figs/2019-06-14-Pronosticos/unnamed-chunk-51-1.png)


Al comparar los modelos podemos evidenciar lo siguiente



{% highlight r %}
AR<-arima(Tasa_desempleo, order = c(1,0,0))
MA<-arima(Tasa_desempleo, order = c(0,0,1))
AR_fit<-Tasa_desempleo - resid(AR)
MA_fit<-Tasa_desempleo - resid(MA)
cor(AR_fit,MA_fit) # COrrelación fuerte
{% endhighlight %}



{% highlight text %}
## [1] 0.9081761
{% endhighlight %}



{% highlight r %}
AIC(AR)->AIC_AR
AIC(MA)->AIC_MA
BIC(AR)->BIC_AR
BIC(MA)->BIC_MA
cbind(AIC_AR,AIC_MA,BIC_AR,BIC_MA)
{% endhighlight %}



{% highlight text %}
##        AIC_AR AIC_MA   BIC_AR   BIC_MA
## [1,] 54.25869  68.94 57.09201 71.77332
{% endhighlight %}


En el siguiente post se trabajará más a profundidad este tema.



