---
title: "Uso de Tidyverse en la creación de modelos"
output: html_document
---






## Tidyverse para el diseño y despliegue de modelos.

[Tidyverse](https://www.tidyverse.org/) es un compendio de paquetes de R, que le permitirá desarrollar modelos y análisis de datos de manera optima. 


{% highlight r %}
install.packages("tidyverse")
{% endhighlight %}



Pero ¿Cómo se trabaja bajo este esquema?, lo primero a tener presente es como manipular los datos y paso seguido el diseño de las secuencias con los pipe, para poder así crear los modelos. A continuación trabajaré un ejemplo básico, que aclara el uso de está potente herramienta.


Suponga el ejemplo clásico de `iris`, en donde quiere proyectar el tamaño del Sepalo de las especies, lo primero a trabajar es la agrupación de los datos.


{% highlight r %}
# Partición de los datos
iris_split <- iris %>%
  initial_split(strata = Species)

iris_train <- training(iris_split)
iris_test <- testing(iris_split)
{% endhighlight %}



{% highlight r %}
iris%>%
  ggplot(aes(Sepal.Length,Petal.Length, color=Species))+
  geom_point()+
  geom_smooth(method = 'lm')
{% endhighlight %}

![center](/figs/2020-04-03-Tidyverse/unnamed-chunk-54-1.png)



{% highlight r %}
iris%>%
  group_by(Species)
{% endhighlight %}



Paso seguido se crea el modelo con una carácteristica puntual, se hará por especies, lo cual quiere decir que el modelo se creará por listas


{% highlight r %}
iris%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 2
##   Species    lm_model
##   <fct>      <list>  
## 1 setosa     <lm>    
## 2 versicolor <lm>    
## 3 virginica  <lm>
{% endhighlight %}

Una vez creado el objeto `lm_model` se procede a crear un nuevo objeto que contenga los estadísticos necesarios.


{% highlight r %}
iris%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))%>%
  mutate(stats_model=map(lm_model,tidy,conf.int=TRUE))
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 3
##   Species   lm_model stats_model   
##   <fct>     <list>   <list>        
## 1 setosa    <lm>     <tibble [4 × …
## 2 versicol… <lm>     <tibble [4 × …
## 3 virginica <lm>     <tibble [4 × …
{% endhighlight %}


Para visualizar los estadísticos se usa la función `unnest`


{% highlight r %}
iris%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))%>%
  mutate(stats_model=map(lm_model,tidy,conf.int=TRUE))%>%
  unnest(stats_model)
{% endhighlight %}



{% highlight text %}
## # A tibble: 12 x 9
##    Species lm_model term  estimate
##    <fct>   <list>   <chr>    <dbl>
##  1 setosa  <lm>     (Int…    2.35 
##  2 setosa  <lm>     Sepa…    0.655
##  3 setosa  <lm>     Peta…    0.238
##  4 setosa  <lm>     Peta…    0.252
##  5 versic… <lm>     (Int…    1.90 
##  6 versic… <lm>     Sepa…    0.387
##  7 versic… <lm>     Peta…    0.908
##  8 versic… <lm>     Peta…   -0.679
##  9 virgin… <lm>     (Int…    0.700
## 10 virgin… <lm>     Sepa…    0.330
## 11 virgin… <lm>     Peta…    0.946
## 12 virgin… <lm>     Peta…   -0.170
## # … with 5 more variables:
## #   std.error <dbl>,
## #   statistic <dbl>,
## #   p.value <dbl>, conf.low <dbl>,
## #   conf.high <dbl>
{% endhighlight %}

Una forma de ver este resultado es a través de un gráfico


{% highlight r %}
iris%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))%>%
  mutate(stats_model=map(lm_model,tidy,conf.int=TRUE))%>%
  unnest(stats_model)%>%
  filter(term!='(Intercept)')%>%
  ggplot(aes(estimate,Species))+
  geom_point()+
  geom_errorbarh(aes(xmin=conf.low,xmax=conf.high,height = .3))+
  facet_wrap(~term, scales = 'free')
{% endhighlight %}

![center](/figs/2020-04-03-Tidyverse/unnamed-chunk-59-1.png)

Un aspecto importante a evaluar es el comportamiento de los p-valores para csaber si el parámetro es optimo para trabajar



{% highlight r %}
iris%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))%>%
  mutate(stats_model=map(lm_model,tidy,conf.int=TRUE))%>%
  unnest(stats_model)%>%
  ggplot(aes(p.value))+
  geom_histogram(bins = 3)+
  facet_wrap(~Species)
{% endhighlight %}

![center](/figs/2020-04-03-Tidyverse/unnamed-chunk-60-1.png)

Con todos se puede trabajar. Ahora la predicción, para ello usare las particiones de las bases 



{% highlight r %}
iris_train%>%
  group_by(Species)%>%
  summarize(lm_model = list(lm(Sepal.Length~Sepal.Width+Petal.Length+Petal.Width)))%>%
  mutate(stats_model=map(lm_model,tidy,conf.int=TRUE))%>%
  mutate(prediction=map(lm_model,predict,iris_test))%>%
  unnest(prediction)
{% endhighlight %}



{% highlight text %}
## # A tibble: 108 x 4
##    Species lm_model stats_model
##    <fct>   <list>   <list>     
##  1 setosa  <lm>     <tibble [4…
##  2 setosa  <lm>     <tibble [4…
##  3 setosa  <lm>     <tibble [4…
##  4 setosa  <lm>     <tibble [4…
##  5 setosa  <lm>     <tibble [4…
##  6 setosa  <lm>     <tibble [4…
##  7 setosa  <lm>     <tibble [4…
##  8 setosa  <lm>     <tibble [4…
##  9 setosa  <lm>     <tibble [4…
## 10 setosa  <lm>     <tibble [4…
## # … with 98 more rows, and 1 more
## #   variable: prediction <dbl>
{% endhighlight %}




## Otra alternativa


Un desarrollo que se llama `tidymodels` puede ejecutar este proceso de una manera increiblemente rápida y computacionalmente no es costoso, aunque como tal aun está en desarrollo.



{% highlight r %}
lm_spec <- linear_reg() %>%
  set_engine(engine = "lm")

lm_fit <- lm_spec %>%
  fit(Sepal.Length ~ .,
    data = iris_train
  )
{% endhighlight %}

Se evalua el modelo



{% highlight r %}
lm_fit%>%
  predict(new_data=iris_train)%>%
  mutate(truth=iris_train$Sepal.Length,
         accuracy=.pred/truth)
{% endhighlight %}



{% highlight text %}
## # A tibble: 114 x 3
##    .pred truth accuracy
##    <dbl> <dbl>    <dbl>
##  1  4.99   5.1    0.979
##  2  4.75   4.9    0.969
##  3  4.76   4.7    1.01 
##  4  4.88   4.6    1.06 
##  5  5.04   5      1.01 
##  6  5.37   5.4    0.995
##  7  4.91   4.6    1.07 
##  8  5.02   5      1.00 
##  9  4.90   4.9    1.00 
## 10  5.17   5.4    0.957
## # … with 104 more rows
{% endhighlight %}

Esto es todo por esta entrada, espero les guste.
