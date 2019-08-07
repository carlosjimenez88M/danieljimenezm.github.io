---
layout: archive
permalink: /RProjects/
title: "R Projects"

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

# 2019 

|Título| Tema |  Base de Datos | Código|
| :----| :----| :--------------| :----- | 
|Machine Learning Models with Tidyverse| Machine Learning| [Base de datos](https://cran.r-project.org/web/packages/gapminder/README.html)| [Código](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/Tidy%20for%20Machine%20Learning.R)|
|Practice PCA for NN| Machine Learning|[Pokemon](https://www.kaggle.com/abcsds/pokemon/downloads/pokemon.zip/2)|[PCA](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Rprojects/PCA%20Reduction%20for%20Machine%20Learning.R)|
|Logistic Regression|Estadística|[Pokemon](https://www.kaggle.com/abcsds/pokemon/downloads/pokemon.zip/2)|[Regresión]()|
