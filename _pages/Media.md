---
layout: archive
permalink: /Media/
title: "Media"
output: ioslides_presentation
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

## Intensión

En el siguiente apartado presento algunos videos, libros y articulos que me parecen de que generan algún tipo de aporte a la comunidad de científicos y es por ello que hago una salvedad, no solo presentare temas directamente relacionados con la ciencia de datos, como el desarrollo de algoritmos , sino de todo lo que abarca las matemáticas, la historia , la fisica , avances , descubrimientos y demás.

Intentaré actualizar está sección una vez al mes, con el fin de mostrar lo que se conversa dentro de la comunidad de científicos de datos y otras ciencias (incluyendo en las que no milito), con la intensión de poder generar algo de discución y análisis que al fin de cuentas tiende a ser refrescante.


## Videos 

* [Cuando ya no esté: Yuval Noah Harari (Parte 1/2) | #0](https://www.youtube.com/watch?v=hxuKo_VdM9o), video del autor de Animales a Dioses, en el cual habla del porque los humanos como especie lograron el nivel de desarrollo que otras especies no compartieron, está es la primer parte del video. 

* [Cuando ya no esté: Yuval Noah Harari (Parte 2/2) ](https://www.youtube.com/watch?v=ECwY77VI3QM).

* [Cómo se fotografió un agujero negro por primera vez](https://www.youtube.com/watch?v=LQi2qgzLD10), [Freddy Vega](https://twitter.com/freddier?lang=es) Co Funder de [Platzi](https://platzi.com/) (La mejor academía en educación on-line en America Latina), explica como con Machine Learning y Big Data se logró tomar la primer fotografía de un **Agujero Negro**.

![Homero](http://bp2.blogger.com/_9zh5Kv2YFek/SCef4Lnx1FI/AAAAAAAAASQ/TVp6tNE3V8w/s1600-h/homero.jpg)

* [MATRICES: de los gráficos de Fortnite a la física cuántica](https://www.youtube.com/watch?v=9FKFgNQktkU), Explicación de las matrices en al vida cotidiana .



## Libros 

*[Introducción al aprendizaje estadístico](http://www-bcf.usc.edu/~gareth/ISL/ISLR%20Seventh%20Printing.pdf), de Gareth James, Daniela Witten y otros, Es un libro que nos lleva por un contexto de como abstraer la estadística teoríca en el mundo computacional para así desarrollar aplicaciones geniales.

* [Introducción a Monte Carlo](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.703.5878&rep=rep1&type=pdf),de Christian P. Robert ,Este libro me parece que es uno de los que mejor explica ¿Qué es ? y ¿ Cómo usar? estos metódos de simulación.

* [Empirismo Bayesiano](https://www.amazon.com/Introduction-Empirical-Bayes-Examples-Statistics-ebook/dp/B06WP26J8Q), De David Robinson, es un increible libro que relata como aplicar a fenómenos que parecen aleatorios (Como la toma de decisiones ó el comportamiento de los individuos) tiene un comportamiento que puede ser definido y pronosticado a través de las leyes de Bayes.

* [R para Ciencia de Datos](https://r4ds.had.co.nz/), de Garrett Grolemund y Hadley Wickham, Este libro detalla el uso de R en ciencia de datos , pero a la par da el contexto de como absrtraer problemas y como dar soluciones practicas a ellos.

* [Fundamentos de la visualización de datos](https://serialmentor.com/dataviz/), de Claus O. Wilke, es un increible libro que da la noción de como desarrollar los skills necesarios para comprender el potencial de esta herramienta y como usarla para diferentes tipos de soluciones.




## Articulos.

