#= require 'jquery.simplemodal'

throw 'jQuery Simple Modal not loaded!' unless $.modal
throw 'jQote2 not loaded'               unless $.jqote
throw 'rivets not loaded'               unless window['rivets']
throw 'observable not loaded'           unless window['observable']

$.extend $.modal.defaults,
  closeHTML   : '<a href="#">✖</a>'
  closeClass  : 'close'
  containerId : 'modal'
  modal       : false
  width       : 'auto'
  height      : 'auto'


# Only one modal can be opened at time for now.
opened  = false
count   = 0
view    = null

that = (params...) ->
  throw 'modal: multiple opened modals are not supported yet' if opened

  # Parse first parameter
  if $.type(params[0]) == 'string'
    element = $ params[0]
  else if $.type(params[0]) == 'object'
    options = params[0]

  params.shift()

  # Parse other parameters
  switch arguments.length
    when 0 then throw 'modal: wrong number of arguments, mininum: 1'
    when 2 then buttons = params.pop()
    when 3
      part = options
      [buttons, options] = params

  part = $.extend part or {}, modal, options
  builder.buttongroupable.call part, buttons

  # Copy modal properties to new instance
  unless element
    element ||= $.jqote options.template or templates.default, part
    $(document.body).append element
    element = $('.modal:last')

  # Options for simple modal
  options.onShow = part.opened
  delete options.opened
  delete part.onShow

  options.onClose = part.closed
  delete options.closed
  delete part.onClose

  options.containerId = options.id || "modal-#{count++}"
  delete options.id

  part.instance = element.modal options
  part._simple = part.instance.d
  part.element = element

  part.view = rivets.bind element, modal: observable.call(part)
  part

builder =
  buttongroup:
    parse  : (string) ->
      [action, name] = string.split /\s+=>\s+/
      action: action, name: name, act: @[action]
    buttons:
      # cancel: '.cancel => Cancel'
      cancel:
        action : 'cancel'
        name   : 'Cancelar'
        act    : -> @close()
      # confirm: '.confirm => Confirm'
      confirm:
        action : 'confirm'
        name   : 'Confirmar'
        act    : -> @close()

  # Mixers
  buttongroupable: (buttons) ->
      buttons ||= $.extend {}, builder.buttongroup.buttons
      parsed = {}
      rendered = []

      for name, button of buttons
        button = builder.buttongroup.parse button if $.type(button) is 'string'

        @[button.action] ||= $.proxy button.act, @

        unless @[button.action]
          message  = "modal.buttongroupable: No handler provided for "
          message += "action ##{button.action} of button #{button.name}"
          throw message

        parsed[name] = button
        rendered.push $.jqote templates.button, button

      # TODO implement getter and setter for buttons
      @buttons          = parsed
      @rendered_buttons = rendered


modal =
  state: 'new'
  open : ->
    throw 'modal.open: cannot reopen modal' if @state == 'opened'

    @state = 'opened'
    @instance.open()
  opened: (dialog) ->
    opened = true
    modal.positionate.call @, dialog
    dialog.container.hide().fadeIn()
  close: ->
    throw 'modal.open: cannot reclose modal' if @state == 'closed'
    @state = 'closed'
    @instance.close()

    true
  closed: (dialog) ->
    opened = false

    dialog.container.fadeOut ->
      dialog.container.remove()
      $.modal.close()
      $('body').children('.modal').remove()
      dialog.view && dialog.view.unbind()
  positionate: (dialog) ->
    container = (@_simple or @dialog or dialog).container
    container.css width: 'auto', height: 'auto'
    (@update or @instance.update or dialog.update).call @instance or @, container.height(), container.width()


Object.defineProperty modal, 'position',
  getter: ->
    x: @latitude, y: @logitude
  setter: (value) ->
    @latitude = value.x
    @longitude = value.y
    @positionate()



templates =
  button  : $.jqotec """
    <button class=\"<*= this.action *>\" data-on-click=\"modal.<*= this.action *>\"> <*= this.name *> </button>
  """
  default: $.jqotec """
    <div class=\"modal\">
      <h1 data-text=\"modal.title\"><*= this.title *></h1>
      <div class=\"content\" data-html=\"modal.content\"><*= this.content *></div>
      <div class=\"button-group\">
        <*= this.rendered_buttons.join(' ') *>
      </div>
    </div>
  """

@modal = that