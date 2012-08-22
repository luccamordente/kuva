#= require library/uploader
#= require library/reader
#= require models/order
#= require models/product
#= require models/specification
#= require components/gadget
#= require components/shelf

reader = lib.reader()
gadgets = inherit length: 0
photos = []                     # Proposital array for automatic counting of length
order = null
shelf = null
uploader = null
product = null
specifications = null

kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of record
  order ||= window.order(options.order)
  product ||= window.product(options.default_product)
  specifications ||= window.specification(options.specifications)
  kuva.specs = specifications

  uploader = window.uploader
    url: "/orders/#{order._id}/images/"
    data:
      order_id: order._id

# TODO Move droppable to a component
dropper =
  dragover: (event) -> false
  droped: (event) ->
    files = event.originalEvent.dataTransfer.files
    dropper.overlay.hide();

    if files? && files.length
      reader.read(files)
    else
      alert('error ao receber arquivos')

    false
  readed: (event) ->

    bus.publish
      controller: 'images'
      action: 'uploaded'
      destination: 'flash'
      type: 'request'
      file:
        name: @file.name
        size: @file.size
        type: @file.type
        data: event.target.result

    reader.next();
  errored: (event) ->
    console.error event.target.error
  overlay:
    show: ->
      @element.fadeIn()
    hide: ->
      @element.fadeOut()
  bind: ->

    $(window).bind('dragenter', (event) ->
       console.log('entered')
       dropper.overlay.show()
     ).bind('drop', @droped)

     @overlay.element.bind('dragleave', (event) ->
        console.log('leaved')
        dropper.overlay.hide()
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
    key   = event.key

    # Criar uma photo para cada arquivo selecionado
    for file in files
      # Create photos and associate with order files
      photo = order.photos.build
        name:       file.name
        count:      1
        product_id: product._id

      photo.file(file)

      gadgets[file.key].photo = photo
      photos[key] = photo
      photos.length += ++count

    control.photos.create(count)
  photos:
    create: (count) ->
      $.ajax
        url:      "/orders/#{order._id}/photos"
        type:     'post'
        dataType: 'json'
        error:    @failed
        success:  @created
        data:
          count: count
          photo:
            count:      1
            product_id: product._id
            specification:
              paper: 'glossy'

    created: (response) ->
      ids = response.photo_ids

      for key, photo of photos
        # TODO check if some photo is without id
        photo.specification = window.specification() unless photo.specification

        # TODO gadget.bind(specification)
        rivets.bind gadgets[photo.file().key].element, specification: photo.specification

        photo.specification.subscribe 'paper', $.proxy photo.save, photo
        window.domo = photo

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

  $('#abort').bind 'click', abort
  shelf = kuva.shelf('#files', 'object:last')

  # Setup drag and drop
  dropper.overlay.element = $('#overlay')
  reader.read.as 'dataURL'
  reader.onloadend = dropper.readed
  reader.onerror = dropper.errored
  dropper.bind()

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
    gadgets[event.key].dispatch('uploaded', event)
  );


$(initialize);