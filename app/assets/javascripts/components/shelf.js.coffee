do (parent = kuva, overlay = kuva.overlay) ->

  inputzin = input = flash = null
  timeouts = {}


  that = (selectorzin, selector, flash_selector) ->
    inputzin = inputzin || $(selectorzin)
    input    = input    || $(selector)
    flash    = flash    || $(flash_selector);
    initialize()
    that

  configuration =
    flash:
      css:
        position: 'absolute'


  shelfer = (part) ->
    shelf[part]()
    shelf.current = part


  shelf =
    overlaying: null
    current   : null
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


  handlers =
    resize: ->
      clearTimeout timeouts.resize
      timeouts.resize = setTimeout shelf[shelf.current], 500
    mouse_enter: ->
      shelf.overlaying.addClass('over');
    mouse_leave: ->
      shelf.overlaying.removeClass('over');


  initialize = ->
    input.attr 'disabled', true
    console.error "shelf: Flash for shelf not found" unless flash.length

    bus.on('mouse.enter', handlers.mouse_enter)
       .on('mouse.leave', handlers.mouse_leave)

    $(window).on 'resize', handlers.resize

    # TODO bus.on('interface.initialized', -> )
    $ ready


  ready = ->
    input.attr 'disabled', false
    shelfer 'button'

    flash.css configuration.flash.css


  that.overlay = shelfer

    parent.shelf = that 