
input = flash = null

that = (selector, flash_selector) ->
  input = input || $(selector)
  flash = flash || $(flash_selector);
  initialize()

configuration =
  flash:
    css:
      position: 'absolute'

overlay =
  for: (element) ->
    offset = element.offset()
    return {
      width: element.width()
      height: element.height()
      top: offset.top
      bottom: offset.bottom
    }
  button: ->
    flash.css(@for(input))
  page: ->
    flash.css(@for($(document.body)))
                       
initialize = ->
  input.attr('disabled', true);
  console.error("shelf: Flash for shelf not found") unless flash.length
  # TODO kuva.listen('interface.initialized', -> )
  ready();    


ready = ->
  input.attr('disabled', false);
  overlay.button()
  flash.css(configuration.flash.css)


that.overlay = overlay;

kuva.shelf = that