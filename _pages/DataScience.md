---
layout: archive
permalink: /Data-Science/
title: "Cursos"
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



## About me


* Data Scientist ;
* Passionate about Anomalies Detection, Data Visualization Reinforcement Learning, Experimental Science and Empirical Bayes Application.
* I working with : Data Science , Modeling Statistics , Neural Networks, Supervised Learning and Unsupervised Learning.
* Hobbies : Political History, Climbing and Cook

## Who I´ve worked with




<img src="
https://carlosjimenez88m.github.io/danieljimenezm.github.io/images/Work.png" alt="hi" class="inline"/>

##  Data Science tools


<img src="
https://carlosjimenez88m.github.io/danieljimenezm.github.io/images/tools.png" alt="hi" class="inline"/>
##  [Some] Projects


<img src="
https://carlosjimenez88m.github.io/danieljimenezm.github.io/images/projects.png" alt="hi" class="inline"/>
