do (parent = kuva, overlay = kuva.overlay) ->

  inputzin = input = flash = null


  that = (selectorzin, selector, flash_selector) ->
    inputzin = inputzin || $(selectorzin)
    input = input || $(selector)
    flash = flash || $(flash_selector);
    initialize()
    that

  configuration =
    flash:
      css:
        position: 'absolute'

  shelf =
    buttonzin: ->
      overlay(flash).at inputzin
    button: ->
      overlay(flash).at input
    page: ->
      overlay(flash).at document.body

  initialize = ->
    input.attr 'disabled', true
    console.error "shelf: Flash for shelf not found" unless flash.length
    # TODO kuva.listen('interface.initialized', -> )
    $ ready


  ready = ->
    input.attr 'disabled', false
    shelf.button()
    flash.css configuration.flash.css


  that.overlay = shelf

  parent.shelf = that