---
layout: archive
permalink: /Projects/
title: "Projects"
image: "/images/Perfil2.jpg"
---
{% include base_path %}
{% include group-by-array collection=site.posts field="tags" %}

{% for tag in group_names %}
  {% assign posts = group_items[forloop.index0] %}
  <h2 id="{{ tag | slugify }}" class="archive__subtitle">{{ tag }}</h2>
  {% for post in posts %}
    {% include archive-single.html %}
  {% endfor %}
{% endfor %}

En esta sección encontrará el código para distintos temas, también presentaré un análisis corto sobre las principales conclusiones del trabajo desarrollado.
El objetivo de este proyecto es aportar a la comunidad en español de [R4DS](https://github.com/rfordatascience)


![](https://github.com/rfordatascience/tidytuesday/blob/master/static/tt_logo.png?raw=true)

# 2020

|Título| Tema |  Base de Datos | Código|
| :----| :----| :--------------| :----- | 
|Machine Learning Models with Tidyverse| Machine Learning| [Base de datos](https://cran.r-project.org/web/packages/gapminder/README.html)| [Código](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Tidy%20for%20Machine%20Learning.R)|
|Practice PCA for NN| Machine Learning|[Pokemon](https://www.kaggle.com/abcsds/pokemon/downloads/pokemon.zip/2)|[PCA](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/PCA%20Reduction%20for%20Machine%20Learning.R)|
|Logistic Regression|Estadística|[Pokemon](https://www.kaggle.com/abcsds/pokemon/downloads/pokemon.zip/2)|[Regresión](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Regresio%CC%81n%20Log%C3%ADstica.R)|
|Selección de modelos|Machine Learning|[Pokemon](https://www.kaggle.com/abcsds/pokemon/downloads/pokemon.zip/2)|[Validación](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Seleccio%CC%81n%20de%20modelos.R)|
|Text relations themes in Bob Ross|text mining|[bob_ross](https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-08-06/bob-ross.csv)|[code](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Bob%20Ross%20.R)|
|Statistical Modeling |Statistics|Data|[Código](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Modeling%20statistical%20.R)|
|Intro to deep learning| Deep Learning| [Data](https://raw.githubusercontent.com/juanklopper/MachineLearningDataSets/master/CTG.csv)|[code](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Deep-learning.R)|
|Tidymodels| Machine Learning- stats| [Data](https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-02-04/readme.md)|[code](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/tidyverse_20200213.R)|
|Machine Learning Models| Machine Learning| [Data](https://github.com/rfordatascience/tidytuesday)|[code](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/20200215-SVMTIDY.Rmd)|
|NPL Maluma| NPL| [Data](https://www.letras.com/maluma/4-babys/)|[code](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/NPL_maluma.R)|





