---
layout: archive
title: "Sobre mi"
permalink: /about/
header:
  image: "/images/imagen2.png"
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

Soy un apasionado por la ciencia de datos, la estadística aplicada y las ciencias experimentales a través de herramientas computacionales y cognitivas, las cuales me han permitido el desarrollo de modelos predictivos y exploratorios aplicados al mundo real tanto en instituciones públicas como privadas.


Mis principales areas de trabajo son:

* Visuaización de Datos;
* Análisis de Anomalías ;
* Detección de Fraudes;
* Diseño de experimentos;
* Modelamiento Estadístico ;
* Ciencia de Datos aplicada;
* Machine Learning por Reforzamiento;
* Análisis Bayesiano

Mientras que mis lineas de investigación son:

* Psicología y Ciencia de Datos;
* Ciencias Experimentales;
* Criminalidad estudiada desde la ciencia de datos;
* Empirical Bayes;
* Análisis de sentimientos.

Trabajo principalmente con **R** (el que no conoce a Dios a cualquier santo le reza),
más domino **SQL** (Bases de datos), **Python** (En caso de ser necesario), y **Octave** (Diseño de prototipos)

En los útlimos tiempos trabajo el tema de reporteria y documentación con **Markdown**, después de ver que es igual de eficiente a *LaTeX*, aunque este útimo es más eficiente para desarrollar documentación personalizada.

En mis tiempos libres me dedico a :

* Música: Toco guitarra acústica en distintos bares en Medellín , a veces canto (no es lo mío);
* Ciclismo de montaña;
* Cocina: Como buen hombre del siglo XXI!!! ;
* Lectura: Tengo una debilidad por los libros, en especial la novela policial.


### Algunos apuntes curiosos

Creo que la ecuación más hermosa del mundo es la de *Poisson* y que aplicada a modelos de ML resolvera los problemas de temporalidad  a través de aprendizaje de refuerzo.

Durante los primeros años de mi vida profesional me dedique al desarrollo económico y a la historia política latinoamericana, después me aburrí y me pase a trabajar temas de Economía Criminal.

Tuve una banda de flamenco con unos amigos Árabes en Texas! , antes de eso fuí pianista y bajista en distintas bandas de metal en Colombia y Chile.

Siempre he sido profesor y siempre lo seré.

Cuando era pequeño quería ser Filósofo, y aun lo quiero!

En el 2012 escribí una obra de teatro *"El bastardo sentimental"*, la cual *Leandro López* (Actor Colombiano) interpreto en el teatro libre (Bogotá) una única vez.

### Apuntes no tan curiosos

Tengo un libro llamado *"Economics and Religion"* , si lo quiere leer, digame y con gusto se lo compartire, habla mal de la religión católica, en especial de varios papas (todos hermanos), desde un estudio económico serio (historia economíca comparativa).

Hoy en día escribo un texto sobre *"La visualización de datos"* un tema que me apasiona.

A nivel de literatura estoy terminando un cuento titulado *"Gruñon y la interpretación del ser desde la biografía de Freddysiño"*, algún día lo comparto, pretendo que no tenga un genero especifico.
