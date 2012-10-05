#= require controllers/kuva
#= require library/shims
#= require library/framework/bus
#= require library/framework/record/adapters/rivets
#= require library/uploader
#= require library/reader
#= require bootstrap-tooltip
#= require models/order
#= require models/product
#= require models/specification
#= require components/gadget
#= require components/shelf
#= require ui/modal

reader         = lib.reader()
photos         = []                     # Proposital array for automatic counting of length
gadgets        = {}
products       = null
order          = null
shelf          = null
uploader       = null
specifications = null

kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of record
  order                    ||= window.order(options.order)
  control.defaults.product ||= window.product(options.default_product)
  specifications           ||= window.specification(options.specifications)
  kuva.orders.products       = products = window.product.cache = options.products


  uploader = window.uploader
    url: "/pedidos/#{order._id}/images/"
    data:
      order_id: order._id

# TODO Move droppable to a component
dropper =
  dragover: (event) -> false
  droped  : (event) ->
    files = event.originalEvent.dataTransfer.files
    dropper.overlay.hide();

    if files? && files.length
      reader.read(files)
    else
      alert('error ao receber arquivos')

    false
  readed: (event) ->

    bus.publish
      controller  : 'images'
      action      : 'uploaded'
      destination : 'flash'
      type        : 'request'
      file        :
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
  defaults:
    photo: undefined
    product: undefined
  modal: undefined
  file_selected: (event) ->
    file = event.file
    key   = event.key
    count = 0

    # Create a new gadget and display it
    gadget = gadgets[key] = window.gadget().show()

    # Criar uma photo para arquivo selecionado
    gadget.photo = photo = order.photos.build
      name       : file.name
      count      : 1
      product    : control.defaults.product
      product_id : control.defaults.product._id

    gadget.files ||= []
    gadget.files.push file

    # Store photo for later usage
    photos.push photo

    # update other interface
    # counters, order price, etc
  files_selected: (event) ->
    # Create default model
    control.defaults.photo = photo = order.photos.build
        name          : 'Foto Padrão'
        count         : 1
        paper         : 'glossy'
        product       : control.defaults.product
        product_id    : control.defaults.product._id
        specification : window.specification()


    # TODO create a deferred
    buttons = ['confirm => Pronto <i>Definir e continuar</i>']

    assigns =
      title   : "Você selecionou <span><b data-text=\"modal.amount\">#{event.amount}</b> fotos</span>"
      confirm : control.selection_confirmed
      amount  : 0
      copies  : 'nenhuma cópia'
      size    : photo.size || '10x15'
      paper   : 'Brilhante'

    mass = gadget '#defaults_gadget',
      data:
        source: kuva.service.url + '/assets/structure/generic-temporary-gadget-photo.jpg'

    # Display modal and gadget
    confirm = modal assigns, buttons, template: templates.modal.files_selected
    mass.photo = photo
    mass.show()

    # Forward photo updates to resume
    # TODO Add support to extended keypaths to observable
    photo.subscribe 'count', ->

      confirm.copies = if +@count
        word = 'cópia'
        word += 's' if +@count > 1
        "#{@count} #{word}"
      else
        'nenhuma cópia'

    photo.specification.subscribe 'paper', ->
      # TODO Revers key with value in hash
      confirm.paper = specification.paper[photo.specification.paper]

    photo.subscribe 'product_id', (product_id) ->
      confirm.size = product.find(product._id).name

    # Positionate and display modal and gadget
    mass.image.size null, 250

    # Bind photo to gadget
    mass.tie()

    # Confirmation animation
    control.modal = confirm

    interval = setInterval ->
      if control.modal.amount < event.amount
        control.modal.amount++
      else
        clearInterval interval
    , 30

    # Create photos records
    control.photos.create event.amount

  selection_confirmed: ->
    # TODO Use animations only when css3 animations
    # is not possible
    # Animate sidebar
    $('#aside').animate width: '9em', padding: '1em'
    $('#main').animate padding: '0 11em 0 0'
    $('#main-add').width 'auto'
    control.modal.close()

    # TODO change json to a getter to_json
    defaults = control.defaults.photo.json()
    console.log('defaults', defaults)

    for photo in photos
      for name, value of defaults

        console.log('setting default', name, value)
        # TODO make record support setting of association attributes
        if name.indexOf('_attributes') != -1
          association_name = name.replace '_attributes', ''
          for attribute, value of defaults[name]
            photo[association_name][attribute] = value
        else
          photo[name] = value


    false

  first_files_selection: ->
    $('#main-add').slideUp()
    bus.off 'files.selected', @callee

  thumbnailed: (event) ->
    # todas miniaturas construidas
  photos:
    create: (count) ->
      $.ajax
        url      : "/pedidos/#{order._id}/photos"
        type     : 'post'
        dataType : 'json'
        error    : @failed
        success  : @created
        data:
          count: count
          photo:
            count     : 1
            product_id: control.defaults.product._id
            specification_attributes:
              paper: 'glossy'

      true
    created: (response) ->
      ids = response.photo_ids

      for key, gadget of gadgets
        photo = gadget.photo

        continue if photo._id?

        gadget.tie ids.shift()

        # TODO photo.gadget().unlock()
        uploader.upload gadget.files[gadget.files.length - 1]

    failed: (xhr, status, error) ->
      message  = "control.photos.failed: Failed creating photos. \n"
      message += "Request Message: #{status} - #{error} \n"
      message += "Enviroment: \n"
      message += "order: #{JSON.stringify(order.json())}"
      throw message

  file_uploaded: (event) ->
    photo = photos[event.key]

    # associate and save image
    photo.images.create(_id: event.image_id)
  closed: ->
    # call order model close
    # update interface for order closing


window.domo = control

# Module methods
initialize = ->

  $('#abort').bind 'click', abort

  # Hide sidebar
  $('#aside').css width: 0, padding: 0
  $('#main').css paddingRight: 0
  $('#main-add').width '100%'


  shelf = kuva.shelf('.add-files', 'object:last')

  # Setup drag and drop
  dropper.overlay.element = $('#overlay')
  reader.read.as 'dataURL'
  reader.onloadend = dropper.readed
  reader.onerror = dropper.errored
  dropper.bind()

  # TODO Better listeners interface, put key on event listener
  #      and move inside gadget initializer
  bus.listen('file.selected', control.file_selected)
  .listen('files.selected', control.files_selected)
  .listen('files.selected', control.first_files_selection)
  .listen('reader.loadstart', (event) ->
    gadgets[event.key].dispatch('loadstart', event)
  )
  .listen('reader.progress', (event) ->
    gadgets[event.key].dispatch('progress', event)
  )
  .listen('reader.loadend', (event) ->
    gadgets[event.key].dispatch('loadend', event)
  )
  .listen('reader.abort', (event) ->
    gadgets[event.key].dispatch('abort', event)
  )
  .listen('thumbnailer.progress', (event) ->
    gadgets[event.key].dispatch('thumbnailing', event)
  )
  .listen('thumbnailer.encoding', (event) ->
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


  $("[rel=tooltip]").tooltip()

templates =
  modal:
    files_selected: $.jqotec """
        <div class=\"modal\">
          <h1><*= this.title *></h1>
          <div class=\"content\">
            <h2>
              <i>Como vai querer a maioria delas? </i> <br />
              Escolha o <u>tamanho</u>, <u>tipo de papel</u> e <u>quantidade de cópias</u> abaixo: <br />
              <small>Note que você pode altera-las individualmente depois.</small>
            </h2>
            <div id=\"defaults_gadget\"></div>
            <div>
              <b data-text=\"modal.copies\">1</b> de cada
              tamanho <b data-text=\"modal.size\">10x15</b>
              papel <b data-text=\"modal.paper\">fosco</b>
            </div>
          </div>

          <div class=\"button-group\">
            <*= this.rendered_buttons *>
          </div>
        </div>
      """

$(initialize);