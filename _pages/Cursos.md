---
layout: archive
permalink: /Cursos/
title: "Presentaciones"

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

En esta sección reposa algunas de las presentaciones de las clases y capacitaciones que he dictado , a la par de los eventos en los que he participado.

Por otra parte también están los apuntes de clases, material de libre uso para quien lo desee. 

## Ciencia de datos
### 2019
[Diseño y creación de clusters](https://www.slideshare.net/DanielJimnez56/cluster-132474391)



## Apuntes de clases
### Ciencia de Datos 
* [Modelos jerárquicos bayesianos](https://github.com/carlosjimenez88M/danieljimenezm.github.io/blob/master/Notas/Bayesiana.pdf)

