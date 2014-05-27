---
layout: page
title: Kontakt
permalink: /kontakt/

menu:
  parent: main
  position: 7
---
Du kan komme i kontakt med DSIO Håndbold på flere måder. Enten ved at bruge kontaktformularen her eller gennem vores [Facebook side](https://www.facebook.com/Dsiohaandbold) eller [Facebook gruppe](https://www.facebook.com/groups/30303969064/).

## Kontaktformular
<form role="form" action="//forms.brace.io/mail@dsiohaandbold.dk" method="post">
  <input type="hidden" name="_next" value="{{site.url}}/kontakt/?type=success&flash=Tak for mailen, vi vender tilbage.">
  <div class="form-group">
    <label for="name">Navn</label>
    <input type="text" class="form-control" id="name" name="name" placeholder="Navn">
  </div>
  <div class="form-group">
    <label for="email">Email</label>
    <input type="email" class="form-control" id="email" name="_replyto" placeholder="Email">
  </div>
  <div class="form-group">
    <label for="message">Besked</label>
    <textarea rows="5" class="form-control" id="message" name="message"></textarea>
  </div>
  <button type="submit" class="btn btn-primary">Send</button>
</form>

<script src="//cdnjs.cloudflare.com/ajax/libs/purl/2.3.1/purl.min.js"></script>
<script src="/assets/js/flash.js"></script>
