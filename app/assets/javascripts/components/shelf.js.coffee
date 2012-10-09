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
    overlaying: null
    mouse_enter: ->
      shelf.overlaying.addClass('over');
    mouse_leave: ->
      shelf.overlaying.removeClass('over');
    buttonzin: ->
      @overlaying = inputzin
      flash.css width:1, height:1
      # overlay(flash).at inputzin
    button: ->
      @overlaying = input
      overlay(flash).at input
    page: ->
      @overlaying = $ document.body
      overlay(flash).at document.body

  initialize = ->
    input.attr 'disabled', true
    console.error "shelf: Flash for shelf not found" unless flash.length

    bus.on('mouse.enter', shelf.mouse_enter)
    .on('mouse.leave', shelf.mouse_leave)

    # TODO bus.on('interface.initialized', -> )
    $ ready


  ready = ->
    input.attr 'disabled', false
    shelf.button()
    flash.css configuration.flash.css


  that.overlay = shelf

  parent.shelf = that