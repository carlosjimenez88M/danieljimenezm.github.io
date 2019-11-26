---
layout: archive
permalink: /Courses/
title: "Presentations"

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

![](https://gaussianos.com/images/Futurama_no-convergente.JPG)
En la presente sección encontrará las presentaciones y el material de clase por institución Universitaria y tema dado. Los códigos para las clases son de uso público y si desean comentarlos o hacer versiones sobre los mismos agradezco que los compartan puesto que ello ayuda a la divulgación sobre estos temas y mejoras en la practica.



## Universidad Nacional 

| Curso | Descripción|
|:------|:-----|
|[Big Data](https://github.com/carlosjimenez88M/Curso-de-Big-Data-e-Ingenieria-de-datos/blob/master/README.md) |Curso Introductorio|



## Unipanamericana



## Educación Futuro



