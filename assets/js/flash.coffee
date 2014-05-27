---
---
url = $.url()
msg = url.param 'flash'

if msg
  flash = $ '#flash'
  flash.hide().removeClass 'hidden'
  type = url.param 'type'
  flash.addClass 'alert-' + type
  flash.find('span').text msg
  flash.show()
