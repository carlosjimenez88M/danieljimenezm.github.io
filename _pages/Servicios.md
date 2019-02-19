---
layout: archive
title: "Servicios"
permanlink: /Servicios/
header:
  image: "/images/Servicio2.png"
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





Los productos y servicios que desarrollo se despliegan en tres áreas principales y dos consecuentes.



### Estadística Aplicada

La estadística aplicada es la verdadera revolución del siglo XXI, aplicada en temas tan diversos como Marketing ó diseño de políticas públicas, este instrumento de entendimiento es tan poderoso como eficaz en todo lo que tiene que ver con tomas de decisiones y anteponerse a posibles escenarios del mundo real.

En este campo mis áreas de actuación son:

* Análisis Exploratorio de Datos
* Muestro
* Diseño y Análisis de encuestas
* Análisis de anomalías
* Modelos Econométricos
* Marketing Analytics
* Análisis de recursos humanos
* Diseño de experimentos
* Modelamiento estadístico
* Test A/B
* Forecasting
* Análisis Bayesiano de datos

<img src="/images/Anomalias.png" alt="hi" class="inline"/>

### Ciencia de datos

El poder del las ciencias de la computación aplicado a patrones matemáticos y estadísticos es la razón de ser de la *ciencia de datos* y el *Machine Learning*.

En este campo mis áreas de trabajo son

* Clasificación
* Segmentación
* Text Mining
* Detección de fraudes y anomalías
* Análisis no supervisado
* Análisis Supervisado
* Visualización de datos
* Dashboard
* Big Data Science
* Churn models
* Ciclo de vida de clientes
* Up sell & Cross sell
* Modelos predictivos
* Aprendizaje de máquina por refuerzo

<img src="/images/Servicio1.png" alt="hi" class="inline"/>

### Capacitación y educación personalizada

Desde el inicio de mi actividad profesional, siempre he trabajado como acádemico, en áreas tan diferentes como la historia del poder  hasta programación, tanto que este oficio de educador lo convertí en un arte y mi razón de ser, a través de metódos cognitivos y computacionales (para el desarrollo del pensamiento lógico).

Mis cursos y capacitaciones permanentes son:

* Desarrollo de indicadores de gestión
* Big Data y Data Science
* Matemáticas Aplicadas
* Habilidades coorporativas
* Innovación
* Excel para negocios
* Internet de las cosas
* Análitica
* Metodología de la investigación.

<img src="/images/Clases.JPG" alt="hi" class="inline"/>


### Categorías consecuentes

El tema de *reportería personalizada, masiva y empresarial* han sido resultantes de mis gustos al trabajar todos estos años entre los sectores públicos y privados, al igual que el desarrollo de *dashboard* a la medida o necesidad del cliente, estos trabajados con herramientas open-source (Shiny, Markdown, LaTeX, Beamer).


### Algunos de los lugares donde he trabajado


<img src="/images/Work.png" alt="hi" class="inline"/>


### Algunos de mis proyectos

<img src="/images/projects.png" alt="hi" class="inline"/>
