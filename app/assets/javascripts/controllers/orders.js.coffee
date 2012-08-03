#= require library/uploader
#= require library/reader
#= require models/order
#= require components/gadget
#= require components/shelf

reader = lib.reader()
gadgets = {}
order = null
shelf = null

kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of record
  order ||= window.order(options.order)

# TODO Move droppable to a component
droppable =
  dragover: (event) -> false
  droped: (event) ->
    files = event.originalEvent.dataTransfer.files
    droppable.overlay.hide();

    if files? && files.length
      reader.read(files)
    else
      alert('error ao receber arquivos')

    false
  readed: (event) ->

    bus.publish(
      controller: 'images'
      action: 'uploaded'
      destination: 'flash'
      type: 'request'
      file:
        name: @file.name
        size: @file.size
        type: @file.type
        data: event.target.result
    )

    reader.next();
  errored: (event) ->
    console.error(event.target.error)
  overlay:
    show: ->
      @element.fadeIn()
    hide: ->
      @element.fadeOut()
  bind: ->

    $(window).bind('dragenter', (event) ->
       console.log('entered')
       droppable.overlay.show()
     ).bind('drop', @droped)

     @overlay.element.bind('dragleave', (event) ->
        console.log('leaved')
        droppable.overlay.hide()
     ).bind('dragover', @dragover).bind('drop', @droped)

# Setup commands
abort = ->
  reader.abort()

control =
  file_selected: (event) ->
    file = event.file

    # Create a new gadget and display it
    gadgets[event.key] = gadget().show()

    # update other interface
    # counters, order price, etc
  finished: (event) ->
    # criar uma photo para cada imagem selecionad
    console.log event
    # photos = []

    # files.each ...
        # Create and associate photo with order
    #   photos.push order.photos.build(file)
    #   photo.image = image
    # end
    #
    # uploader.upload(order.images)

  file_uploaded: (event) ->
    # update photo with image
    # save photo
  closed: ->
    # call order model close
    # update interface for order closing

# Module methods
initialize = ->
  $('#abort').bind('click', abort)
  $.jqotetag('*')
  # uploader('#files', {thumbnailer: reader})

  shelf = kuva.shelf('#files', 'object:last')

  # Setup drag and drop
  droppable.overlay.element = $('#overlay')
  reader.read.as('dataURL');
  reader.onloadend = droppable.readed
  reader.onerror = droppable.errored
  droppable.bind()
  #  reader.read.as('dataURL')

  # TODO Better listeners interface, put key on event listener
  #      and move inside gadget initializer
  bus.listen('file.selected', control.file_selected)
  .listen('file.uploaded', control.file_uploaded)
  .listen('reader.loadstart', (event) ->
    gadgets[event.key].dispatch('loadstart', event)
  ).
  listen('reader.progress', (event) ->
    gadgets[event.key].dispatch('progress', event)
  ).
  listen('reader.loadend', (event) ->
    gadgets[event.key].dispatch('loadend', event)
  ).
  listen('reader.abort', (event) ->
    gadgets[event.key].dispatch('abort', event)
  ).
  listen('thumbnailer.progress', (event) ->
    gadgets[event.key].dispatch('thumbnailing', event)
  ).
  listen('thumbnailer.encoding', (event) ->
    gadgets[event.key].dispatch('encoding', event)
  ).
  listen('thumbnailer.thumbnailed', (event) ->
    gadgets[event.key].dispatch('thumbnailed', event)
  ).listen('thumbnailer.finished', control.finished)

$(initialize);