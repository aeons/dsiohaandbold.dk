---
permalink: /kalender/
title: Kalender
layout: post

menu:
  parent: main
  position: 4
---
<ul>
  {% for d in site.data.generated.calendar %}
  {% if d.date > '02014-03-01' %}
  <li>
    {{ d.date | to_datetime | localize: '%A d. %-d. %B, %Y' | capitalize }}
    <ul>
      {% assign matches = d.matches | sort: 'dtstart' %}
      {% for m in matches %}
        {% if m.type == 'match' %}
          {% include calendar_match.html match=m %}
        {% elsif m.type == 'msg_cup' %}
          {% include calendar_msg_cup.html msg_cup=m %}
        {% endif %}
      {% endfor %}
    </ul>
  </li>
  {% endif %}
  {% endfor %}
</ul>
