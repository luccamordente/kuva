#= require library/uploader
#= require library/reader
#= require models/order
#= require components/gadget
#= require components/shelf

reader = lib.reader()
gadgets = inherit(length: 0)
photos = []                     # Proposital array for automatic counting of length
order = null
shelf = null
uploader = null


kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of record
  order ||= window.order(options.order)
  uploader = window.uploader(data: order_id: order._id)

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
  thumbnailed: (event) ->
    files = event.files
    count = 0
    key = event.key

    # Criar uma photo para cada arquivo selecionado
    for file in files
      # Create photos and associate with order files
      photo = order.photos.build
        name: file.name
        count: 1

      photo.file(file)
      # TODO associate gadget with photo gadgets[file.key].photo = photo

      photos[key] = photo
      photos.length += ++count

    control.photos.create(count)
  photos:
    create: (count) ->
      $.ajax
        url: photo.route
        type: 'post'
        data:
          order_id: order._id
          count: count
          photo:
            count: 1
        dataType: 'json'
        success: @created
        error: @failed

    created: (response) ->
      ids = response.photo_ids

      for key, photo of photos
        # TODO check if some photo is without id

        unless photo._id?
          photo._id = ids.shift()
          # TODO photo.gadget().unlock()
          uploader.upload(photo.file())

      true
    failed: ->
      console.error 'control.photos.failed: Failed creating photos.'

  file_uploaded: (event) ->
    photo = photos[event.key]

    # associate and save image
    photo.images.create(_id: event.image_id)
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
  ).
  listen('thumbnailer.finished', control.thumbnailed).
  listen('upload.start', (event) ->
    gadgets[event.key].dispatch('upload', event)
  ).
  listen('upload.progress', (event) ->
    gadgets[event.key].dispatch('uploading', event)
  ).
  listen('upload.complete', (event) ->
    # TODO figure out how get image id control.file_uploaded(event);
    gadgets[event.key].dispatch('uploaded', event);
  );


$(initialize);