---
title: "ML de clasificación"
output: html_document
---



## Tidytuesday


El último `tidytuesday` liderado por [Julia Silge](https://juliasilge.com/blog/hotels-recipes/), intenta generar modelos de clasificación y pronóstico con ello sobre los usuarios que iran con `children` a hospedarse en hoteles.

El desarrollo de los modelos de ella, me parecen con sobradas palabras de admiración increibles y por ello con base a lo aprendido y aportando un poco de mi metodología haré mi versión. A pesar de ser fanático de R debo reconocer que soy nuevo en los `tidymodels` por lo tanto lo empezará a usar a manera de usuario novato en alguna parte de este post.

En el siguiente [link](https://github.com/rfordatascience/tidytuesday) encontrará el set de datos y el diccionario

## Explorando los datos

Lo primero a investigar es como viene dada la estructura de los datos.









{% highlight r %}
hotels%>%
  glimpse()
{% endhighlight %}



{% highlight text %}
## Observations: 119,390
## Variables: 32
## $ hotel                          <chr> …
## $ is_canceled                    <dbl> …
## $ lead_time                      <dbl> …
## $ arrival_date_year              <dbl> …
## $ arrival_date_month             <chr> …
## $ arrival_date_week_number       <dbl> …
## $ arrival_date_day_of_month      <dbl> …
## $ stays_in_weekend_nights        <dbl> …
## $ stays_in_week_nights           <dbl> …
## $ adults                         <dbl> …
## $ children                       <dbl> …
## $ babies                         <dbl> …
## $ meal                           <chr> …
## $ country                        <chr> …
## $ market_segment                 <chr> …
## $ distribution_channel           <chr> …
## $ is_repeated_guest              <dbl> …
## $ previous_cancellations         <dbl> …
## $ previous_bookings_not_canceled <dbl> …
## $ reserved_room_type             <chr> …
## $ assigned_room_type             <chr> …
## $ booking_changes                <dbl> …
## $ deposit_type                   <chr> …
## $ agent                          <chr> …
## $ company                        <chr> …
## $ days_in_waiting_list           <dbl> …
## $ customer_type                  <chr> …
## $ adr                            <dbl> …
## $ required_car_parking_spaces    <dbl> …
## $ total_of_special_requests      <dbl> …
## $ reservation_status             <chr> …
## $ reservation_status_date        <date> …
{% endhighlight %}

Lo primero que voy hacer es filtrar los resultados por las reservas no canceladas , lo cual facilitará el trabajo de construir un modelo de clasificación más exacto.


{% highlight r %}
hotels%>%
  filter(is_canceled==0)%>%
  mutate(
    children=case_when(
     children + babies >0 ~ "children",TRUE~"none" 
    ),
    required_car_parking_spaces=case_when(
      required_car_parking_spaces>0 ~"parking",
      TRUE~"none"
    )
  )%>%
  select(-is_canceled, -reservation_status, -babies)->Hotel_stays
{% endhighlight %}



Lo primero a investigar es : ¿Cómo es la proporción de adultos que van solos y los que van con niños según la categoría del hotel?


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-20-1.png)

Algunas conclusiones interesantes arroja está gráfica:

* En los hoteles de la ciudad cuando van en promedio cuatro adultos no llevan niños;
* Cuando van tres adultos a el `city hotel` la proporción que lleva a niños es del 3.54% mientras que en los `resort` la proporción es del 19.83% , lo que quiere decir es que es seis veces más grande la proporción lo cual arroja un gran insigths sobre el problema a resolver.
* LA diferencia cuando son dos adultos en ambas categorías de hoteles no presenta gran diferencia en la presencia de niños.


Uno de los aprendizajes del post de Julia viene dado al uso de un nuevo paquete que permite conocer a manera estructural las características del dataset , [skirm](https://github.com/ropensci/skimr) que se define como

> provides a frictionless approach to summary statistics which conforms to the principle of least surprise, displaying summary statistics the user can skim quickly to understand their data. It handles different data types and returns a skim_df object which can be included in a pipeline or displayed nicely for the human reader. (https://github.com/ropensci/skimr)



{% highlight r %}
skim(Hotel_stays)
{% endhighlight %}


|                         |            |
|:------------------------|:-----------|
|Name                     |Hotel_stays |
|Number of rows           |75166       |
|Number of columns        |29          |
|_______________________  |            |
|Column type frequency:   |            |
|character                |14          |
|Date                     |1           |
|numeric                  |14          |
|________________________ |            |
|Group variables          |None        |


**Variable type: character**

|skim_variable               | n_missing| complete_rate| min| max| empty| n_unique| whitespace|
|:---------------------------|---------:|-------------:|---:|---:|-----:|--------:|----------:|
|hotel                       |         0|             1|  10|  12|     0|        2|          0|
|arrival_date_month          |         0|             1|   3|   9|     0|       12|          0|
|children                    |         0|             1|   4|   8|     0|        2|          0|
|meal                        |         0|             1|   2|   9|     0|        5|          0|
|country                     |         0|             1|   2|   4|     0|      166|          0|
|market_segment              |         0|             1|   6|  13|     0|        7|          0|
|distribution_channel        |         0|             1|   3|   9|     0|        5|          0|
|reserved_room_type          |         0|             1|   1|   1|     0|        9|          0|
|assigned_room_type          |         0|             1|   1|   1|     0|       10|          0|
|deposit_type                |         0|             1|  10|  10|     0|        3|          0|
|agent                       |         0|             1|   1|   4|     0|      315|          0|
|company                     |         0|             1|   1|   4|     0|      332|          0|
|customer_type               |         0|             1|   5|  15|     0|        4|          0|
|required_car_parking_spaces |         0|             1|   4|   7|     0|        2|          0|


**Variable type: Date**

|skim_variable           | n_missing| complete_rate|min        |max        |median     | n_unique|
|:-----------------------|---------:|-------------:|:----------|:----------|:----------|--------:|
|reservation_status_date |         0|             1|2015-07-01 |2017-09-14 |2016-09-01 |      805|


**Variable type: numeric**

|skim_variable                  | n_missing| complete_rate|    mean|    sd|      p0|    p25|    p50|  p75| p100|hist  |
|:------------------------------|---------:|-------------:|-------:|-----:|-------:|------:|------:|----:|----:|:-----|
|lead_time                      |         0|             1|   79.98| 91.11|    0.00|    9.0|   45.0|  124|  737|▇▂▁▁▁ |
|arrival_date_year              |         0|             1| 2016.15|  0.70| 2015.00| 2016.0| 2016.0| 2017| 2017|▃▁▇▁▆ |
|arrival_date_week_number       |         0|             1|   27.08| 13.90|    1.00|   16.0|   28.0|   38|   53|▆▇▇▇▆ |
|arrival_date_day_of_month      |         0|             1|   15.84|  8.78|    1.00|    8.0|   16.0|   23|   31|▇▇▇▇▆ |
|stays_in_weekend_nights        |         0|             1|    0.93|  0.99|    0.00|    0.0|    1.0|    2|   19|▇▁▁▁▁ |
|stays_in_week_nights           |         0|             1|    2.46|  1.92|    0.00|    1.0|    2.0|    3|   50|▇▁▁▁▁ |
|adults                         |         0|             1|    1.83|  0.51|    0.00|    2.0|    2.0|    2|    4|▁▂▇▁▁ |
|is_repeated_guest              |         0|             1|    0.04|  0.20|    0.00|    0.0|    0.0|    0|    1|▇▁▁▁▁ |
|previous_cancellations         |         0|             1|    0.02|  0.27|    0.00|    0.0|    0.0|    0|   13|▇▁▁▁▁ |
|previous_bookings_not_canceled |         0|             1|    0.20|  1.81|    0.00|    0.0|    0.0|    0|   72|▇▁▁▁▁ |
|booking_changes                |         0|             1|    0.29|  0.74|    0.00|    0.0|    0.0|    0|   21|▇▁▁▁▁ |
|days_in_waiting_list           |         0|             1|    1.59| 14.78|    0.00|    0.0|    0.0|    0|  379|▇▁▁▁▁ |
|adr                            |         0|             1|   99.99| 49.21|   -6.38|   67.5|   92.5|  125|  510|▇▆▁▁▁ |
|total_of_special_requests      |         0|             1|    0.71|  0.83|    0.00|    0.0|    1.0|    1|    5|▇▁▁▁▁ |


Lo que se peude apreciar es la distribución de los datos (lo cual es sumamente importante) y la no ausencia de datos.


Paso seguido empiezo a desarrollar hipótesis , ¿existirá una relación entre el número de adultos y el tiempo de espera cuando hay presencia de niños para el hospedaje ?


El resultado del análisis correlacional es el siguiente :


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-22-1.png)


A pesar que los P-valores tienden a indicar que hay un grado de almacenamiento de información , los R muestran que dichas correlaciones son bastante débiles.

Otro idea podría ser la ¿cómo es la correlación entre el tiempo de espera y los días entre semana a hospedar cuando hay y cuando no presencia de niños? y los resultados son los siguientes


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-23-1.png)


Estás correlaciones son bastante interesantes y permites evitar el efecto de multicolinealidad y VIF. Ahora las correlaciones del tiempo de espera cuando el hospedaje son los fines de semana arrojan resutlados diferentes a esto, pero que dibujan un buen mapa de navegación sobre que construir 


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-24-1.png)

Ahora, se explora el comportamiento de los meses de hospedaje y la presencia de niños.


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-25-1.png)



Se observan algunas pequeñas diferencias por lo cual trabajaré con bootstrap para poder desarrollar un proceso de inferencia estadística.



{% highlight r %}
Hotel_stays%>%
  specify(formula = children~hotel, success = 'children')%>%
  generate(reps = 100, type="bootstrap")%>%
  calculate(stat = "diff in props", order = c("City Hotel","Resort Hotel"))->bootstrap_hotel
visualize(bootstrap_hotel)
{% endhighlight %}

![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-26-1.png)

Se calculan los intervalos de confianza y se desarrolla un análisis gráfico


{% highlight r %}
bootstrap_hotel%>% 
  get_confidence_interval(type = 'percentile', level = 0.95)
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 2
##    `2.5%`  `97.5%`
##     <dbl>    <dbl>
## 1 -0.0151 -0.00611
{% endhighlight %}



Paso seguido se calculan las diferencias sin Bootstrap para poder generar el análisis inferencial



{% highlight r %}
Hotel_stays%>%
  specify(formula = children~hotel, success = 'children')%>%
  calculate(stat = "diff in props", order = c("City Hotel","Resort Hotel"))->obs_diff_props

paste(print("La diferencia entre proporciones de las observaciones es"),obs_diff_props)
{% endhighlight %}



{% highlight text %}
## [1] "La diferencia entre proporciones de las observaciones es"
{% endhighlight %}



{% highlight text %}
## [1] "La diferencia entre proporciones de las observaciones es -0.0108988099999837"
{% endhighlight %}



Se generan los puntos de estimación 

{% highlight r %}
bootstrap_hotel%>%
  get_confidence_interval(type = 'se', point_estimate = obs_diff_props)->hotels_ci_se
  
hotels_ci_se
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 2
##     lower    upper
##     <dbl>    <dbl>
## 1 -0.0154 -0.00637
{% endhighlight %}


{% highlight r %}
visualize(bootstrap_hotel)+
  shade_confidence_interval(endpoints = hotels_ci_se)+
  geom_vline(xintercept = c(-0.01517992,-0.007126829))
{% endhighlight %}

![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-30-1.png)

Parece ser que hay una diferencia entre los meses del año y la estancia con o sin niños!! esta información es supremamente importante.

Paso seguido desarrollaré una hipótesis nula , para concluir como son o si en efecto son diferencias que afecten al desarrollo de un modelo.

{% highlight r %}
Hotel_stays%>%
  specify(formula = children~hotel, success = 'children')%>%
  hypothesize(null='independence')%>%
  generate(reps = 100, type="permute")%>%
  calculate(stat = "diff in props", order = c("City Hotel","Resort Hotel"))->NUll_distribution

Hotel_stays%>%
  specify(formula = children~hotel, success = 'children')%>%
  calculate(stat = "diff in props", order = c("City Hotel","Resort Hotel"))->obs_diff_hotels

visualize(NUll_distribution)+
  shade_p_value(obs_stat = obs_diff_hotels, direction = 'right')
{% endhighlight %}

![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-31-1.png)
La evidencia arroja que no existen diferencias importantes en la presencia de los niños dado el estilo del hotel.



Una última correlación que estudio es entre el tiempo de espera y la necesidad de parking cuando hay hospedaje entre semana 


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-32-1.png)

Las correlaciones son interesantes!!!


POr útimo se evalua el tiempo de hospedaje promedio por país 



{% highlight text %}
## Selecting by std_stady
{% endhighlight %}

![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-33-1.png)
Hay un promedio de días más alto en `Resort` con niños y una acumulación más fuerte en el hospedaje en dos días cuando se está solo.


Para finalizar, se pueden evaluar las correlaciones entre variables y ver como impactan al factor `children`


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-34-1.png)

## Selección de variables para construir el modelo


Usare dos técnicas para evaluar cuales son las variables que más aportan a generar un modelo que pueda pronósticar las clasificaciones que se buscan.

Con un Random Forest buscaré cuales son las variables que más aportan al accuracy de un modelo





![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-36-1.png)

Las variables que ayudan a definir la asistencia de niños o no a los hotetes son :adr, mes de hospedaje y el tipo de hotel.


![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-37-1.png)
Una diferencia con el anterior selector es que la variable `lead time` ayuda a mejorar las probabilidades de definición de la asistencia de `children`.


Para re-afinar esta selección usaré un algoritmo  genético 





{% highlight r %}
library(doMC)
registerDoMC(cores = 4)
ga_ctrl <- gafsControl(functions = rfGA,
                       method = "cv",
                       number = 5,
                       allowParallel = TRUE,
                       genParallel = TRUE, 
                       verbose = FALSE)

set.seed(111)
rf_ga <- gafs(x = train_set[, -11],
              y = train_set$children,
              iters = 10, 
              popSize = 10,
              gafsControl = ga_ctrl,
              ntree = 100)
{% endhighlight %}


El algoritmo indica que las variables con que se tiene que construir el modelo son las siguientes:


{% highlight text %}
## [1] "children"               
## [2] "hotel"                  
## [3] "arrival_date_month"     
## [4] "meal"                   
## [5] "adults"                 
## [6] "stays_in_weekend_nights"
{% endhighlight %}




La versión de Julia se da de la siguiente manera

{% highlight r %}
## Knn
hotel_split <- initial_split(Hotel_stays)

hotel_train <- training(hotel_split)
hotel_test <- testing(hotel_split)

hotel_rec <- recipe(children ~ ., data = hotel_train) %>%
  step_downsample(children) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_zv(all_numeric()) %>%
  step_normalize(all_numeric()) %>%
  prep()

test_proc <- bake(hotel_rec, new_data = hotel_test)
{% endhighlight %}



{% highlight text %}
## Warning: There are new levels in a
## factor: BDI, MWI, BHS, MAC, MLI, NAM,
## AIA, GUY, ASM, NCL, ATF, TJK, SLE
{% endhighlight %}



{% highlight text %}
## Warning: There are new levels in a
## factor: Undefined
{% endhighlight %}



{% highlight text %}
## Warning: There are new levels in a
## factor: 304, 446, 367, 333, 438, 59, 54,
## 70, 90, 144, 213, 289, 397, 453
{% endhighlight %}



{% highlight text %}
## Warning: There are new levels in a
## factor: 278, 250, 362, 401, 398, 370,
## 10, 419, 415, 458, 447, 32, 491, 29, 506,
## 64, 541, 455, 65, 100, 237, 234, 258, 18,
## 284, 301, 313, 332, 350, 368, 412, 417
{% endhighlight %}



{% highlight r %}
knn_spec <- nearest_neighbor() %>%
  set_engine("kknn") %>%
  set_mode("classification")

knn_fit <- knn_spec %>%
  fit(children ~ ., data = juice(hotel_rec))


set.seed(1234)
validation_splits <- mc_cv(juice(hotel_rec), prop = 0.9, strata = children)

knn_res <- fit_resamples(
  children ~ .,
  knn_spec,
  validation_splits,
  control = control_resamples(save_pred = TRUE)
)

knn_res %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary     0.747    25 0.00256
## 2 roc_auc  binary     0.838    25 0.00243
{% endhighlight %}

EL accuracy del Knn es del 82%, lo cual lo convierte en un candidato ideal, pero es mejor ser prudentes y probar con otros modelos.


{% highlight r %}
rf_spec<-rand_forest()%>%
  set_engine("ranger")%>%
  set_mode("classification")

rf_fit <- rf_spec %>%
  fit(children ~ ., data = juice(hotel_rec))
{% endhighlight %}




{% highlight r %}
rf_res <- fit_resamples(
  children ~ .,
  rf_spec,
  validation_splits,
  control = control_resamples(save_pred = TRUE)
)

rf_res %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary     0.838    25 0.00246
## 2 roc_auc  binary     0.921    25 0.00176
{% endhighlight %}


El accuracy del random forest es más alto que el del KNN. A continuación se trabajará con un xgboost




{% highlight r %}
## 
gd_spec<-boost_tree()%>%
  set_engine("xgboost")%>%
  set_mode("classification")

gd_fit <- gd_spec %>%
  fit(children ~ ., data = juice(hotel_rec))

gd_res <- fit_resamples(
  children ~ .,
  gd_spec,
  validation_splits,
  control = control_resamples(save_pred = TRUE)
)

gd_res %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary     0.840    25 0.00288
## 2 roc_auc  binary     0.921    25 0.00183
{% endhighlight %}

EL modelo de gdboost tiene un ajuste del 0.8396 .



{% highlight r %}
### NNET

nnet_spec   <- mlp() %>% 
  set_engine("keras")%>%
  set_mode("classification")


nnet_fit <- nnet_spec %>%
  fit(children ~ ., data = juice(hotel_rec))


nnet_res <- fit_resamples(
  children ~ .,
  nnet_spec,
  validation_splits,
  control = control_resamples(save_pred = TRUE)
)
{% endhighlight %}



{% highlight text %}
## ! Some required packages prohibit parallel processing:  'keras'
{% endhighlight %}



{% highlight r %}
nnet_res %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary       0.5    25       0
## 2 roc_auc  binary       0.5    25       0
{% endhighlight %}
La red no tiene un buen nivel de pronóstico

Por último se trabajará con un SVM y paso seguido se comparan los resultados .



{% highlight r %}
## Support Vector Machine

SVM_spec   <- svm_poly() %>% 
  set_engine("kernlab")%>%
  set_mode("classification")


SVM_fit <- SVM_spec %>%
  fit(children ~ ., data = juice(hotel_rec))
{% endhighlight %}



{% highlight text %}
##  Setting default kernel parameters
{% endhighlight %}



{% highlight r %}
svm_res <- fit_resamples(
  children ~ .,
  SVM_spec,
  validation_splits,
  control = control_resamples(save_pred = TRUE)
)

svm_res %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary     0.793     5 0.00537
## 2 roc_auc  binary     0.869     5 0.00403
{% endhighlight %}


El modelo con el Support Vechor Machine baja su nivel de accuracy.

## Comparación y evaluación de los modelos


{% highlight r %}
knn_res %>%
  unnest(.predictions) %>%
  mutate(model = "kknn") %>%
  bind_rows(rf_res %>%
    unnest(.predictions) %>%
    mutate(model = "random Forest")) %>%
  bind_rows(gd_res %>%
    unnest(.predictions) %>%
    mutate(model = "xgboost")) %>%
  bind_rows(nnet_res %>%
    unnest(.predictions) %>%
    mutate(model = "Nnet")) %>%
    bind_rows(svm_res %>%
    unnest(.predictions) %>%
    mutate(model = "Support Vector Machine")) %>%
  group_by(model) %>%
  roc_curve(children, .pred_children) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
  geom_line(size = 1.5) +
  geom_abline(
    lty = 2, alpha = 0.5,
    color = "gray50",
    size = 1.2
  )
{% endhighlight %}

![center](/figs/2020-02-16-Modelosdeclasificacion/unnamed-chunk-47-1.png)




{% highlight r %}
xg_conf <- gd_res %>%
  unnest(.predictions) %>%
  conf_mat(children, .pred_class)

xg_conf
{% endhighlight %}



{% highlight text %}
##           Truth
## Prediction children none
##   children     9588 1792
##   none         1862 9658
{% endhighlight %}




{% highlight r %}
gd_fit %>%
  predict(new_data = test_proc, type = "prob") %>%
  mutate(truth = hotel_test$children) %>%
  roc_auc(as.factor(truth), .pred_children)
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 3
##   .metric .estimator .estimate
##   <chr>   <chr>          <dbl>
## 1 roc_auc binary         0.921
{% endhighlight %}


El modelo del xgboost tiene un Roc del 0.92.


Este modelo es increiblemente bueno.
