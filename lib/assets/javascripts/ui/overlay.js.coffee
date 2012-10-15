do (parent = kuva) ->

  instance = {}


  that = (selector = '#overlay') ->
    instance = $ selector unless selector == instance.selector
    initialize()
    overlay


  handlers =
    resize: ->


  overlay =
    at: (element) ->
      instance.css css $ element
      if instance.dynamic
        instance.css width: '100%', height: '100%'
    close: ->
      instance.css display: 'none'
    dynamic: ->
      instance.dynamic = true
      @


  css = (element) ->
    offset = element.offset()
    display: 'block'
    height : element.outerHeight()
    width  : element.outerWidth()
    left   : offset.left
    top    : offset.top


  initialize = ->
    $(window).on 'resize', handlers.resize


  $.extend that, overlay

  parent.overlay = that