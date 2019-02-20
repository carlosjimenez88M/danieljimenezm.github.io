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

En esta sección reposa algunas de las presentaciones de clases como eventos en los que he participado.

## Ciencia de datos
### 2019
[Diseño y creación de clusters](https://www.slideshare.net/DanielJimnez56/cluster-132474391)
