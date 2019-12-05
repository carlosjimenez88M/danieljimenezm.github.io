---
layout: archive
permalink: /Media/
title: "Conversaciones con el hombre malvavisco"
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


![](https://http2.mlstatic.com/hombre-malvavisco-cazafantasmas-D_NQ_NP_839883-MLM25634315561_052017-F.webp)

[^1]: tomada de : https://articulo.mercadolibre.com.mx/MLM-585343166-hombre-malvavisco-cazafantasmas-_JM

## Intensión

Conversaciones con el hombre malvavisco son reflexiones sobre problemas cotidianos o no, preguntas existenciales o análisis coyunturales desde un punto científico con lenguaje coloquial en donde el hombre malvavisco representa a la información y su interlocutor los argumentos e hilos conductores sobre la pregunta rectora.


Algunas de estas salídas serán en formato video, o podcast, mientras otras (la gran mayoria) seran escritas.











