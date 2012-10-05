do (parent = kuva) ->

  instance = {}


  that = (selector = '#overlay') ->
    instance = $ selector unless selector == instance.selector
    overlay


  overlay =

    at: (element) ->
      instance.css css $ element

    close: ->
      instance.css display: 'none'


  css = (element) ->
    offset = element.offset()
    display: 'block'
    height : element.outerHeight()
    width  : element.outerWidth()
    left   : offset.left
    top    : offset.top



  $.extend that, overlay

  parent.overlay = that