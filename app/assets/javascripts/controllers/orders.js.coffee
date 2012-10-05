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
#= require components/aside
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
  kuva.order = order

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
        product       : control.defaults.product
        product_id    : control.defaults.product._id
        specification : window.specification({ paper: 'glossy' })
        width         : 320
        height        : 480


    # TODO create a deferred
    buttons = ['confirm.success => Pronto <i>Definir e continuar</i>']

    assigns =
      title       : "Você selecionou <span class=\"amount\"><b data-text=\"modal.amount\">#{event.amount}</b> <span data-text=\"modal.amount_label\">foto</span></span>"
      confirm     : control.selection_confirmed
      amount      : 1
      copies      : '1 cópia'
      size        : photo.size || '10x15'
      paper       : 'Brilhante'

    mass = gadget '#defaults-gadget',
      data:
        source: kuva.service.url + '/assets/structure/generic-temporary-gadget-photo.jpg'

    # Display modal and gadget
    confirm = modal assigns, buttons, template: templates.modal.files_selected, minWidth: 780, minHeight: 500
    mass.photo = photo
    mass.show()
    mass.dispatch 'loadend', photo

    # Forward photo updates to resume
    # TODO Add support to extended keypaths to observable
    photo.subscribe 'count', (count) ->

      confirm.copies = if +count
        word = 'cópia'
        word += 's' if +count > 1
        "#{count} #{word}"
      else
        'nenhuma cópia'

    photo.specification.subscribe 'paper', ->
      confirm.paper = specification.paper[photo.specification.paper]

    photo.subscribe 'product_id', (product_id) ->
      confirm.size = product.find(product._id).name

    # Positionate and display modal and gadget
    mass.image.size null, 250

    # Bind photo to gadget
    mass.tie()

    # TODO check why binding is not working when instantiated
    # Note: this is not a programming error
    photo.specification.paper = photo.specification.paper
    photo.product_id          = photo.product_id
    photo.count               = photo.count

    # Confirmation animation
    control.modal = confirm

    interval = setInterval ->
      if control.modal.amount < event.amount
        control.modal.amount++
      else
        clearInterval interval
      if control.modal.amount <= 2
        control.modal.amount_label = if control.modal.amount == 1 then "foto" else "fotos"
    , 30

    # Create photos records
    control.photos.create event.amount

  selection_confirmed: ->
    # TODO Use animations only when css3 animations
    # is not possible
    # Animate sidebar
    $('#aside').animate width: '9em', padding: '1em' # TODO Move to aside component
    # aside.initialize('#aside', order.photos);



    main = $ '#main'
    main.animate padding: '0 11em 0 0'
    setTimeout ->
      main.css 'width', main.width() - 10
      setTimeout ->
          main.width 'auto'
      , 20
    , 100

    control.modal.close()

    # TODO change json to a getter to_json
    defaults = control.defaults.photo.json()

    delete defaults.width
    delete defaults.height

    for photo in photos
      for name, value of defaults
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
    photo = gadgets[event.key].photo

    # associate and save image
    photo.image_id = event.data.id
    photo.save()
  closed: ->
    # call order model close
    # update interface for order closing


window.domo = control

# Module methods
initialize = ->

  # Hide sidebar
  $('#aside').css width: '9em', padding: '1em'  # TODO Move to aside component

  # $('#main').css paddingRight: 0
  # $('#main-add').width '100%'


  shelf = kuva.shelf('.add-files', 'object:last')

  # Setup drag and drop
  dropper.overlay.element = $('#overlay')
  reader.read.as 'dataURL'
  reader.onloadend = dropper.readed
  reader.onerror = dropper.errored
  dropper.bind()

  # TODO Better listeners interface, put key on event listener
  #      and move inside gadget initializer
  bus.listen('file.selected'       , control.file_selected                                        )
  .listen('files.selected'         , control.files_selected                                       )
  .listen('files.selected'         , control.first_files_selection                                )
  .listen('reader.loadstart'       , (event) -> gadgets[event.key].dispatch('loadstart'   , event))
  .listen('reader.progress'        , (event) -> gadgets[event.key].dispatch('progress'    , event))
  .listen('reader.loadend'         , (event) -> gadgets[event.key].dispatch('loadend'     , event))
  .listen('reader.abort'           , (event) -> gadgets[event.key].dispatch('abort'       , event))
  .listen('thumbnailer.progress'   , (event) -> gadgets[event.key].dispatch('thumbnailing', event))
  .listen('thumbnailer.encoding'   , (event) -> gadgets[event.key].dispatch('encoding'    , event))
  .listen('thumbnailer.thumbnailed', (event) -> gadgets[event.key].dispatch('thumbnailed' , event))
  .listen('thumbnailer.finished'   , control.thumbnailed                                          )
  .listen('upload.start'           , (event) -> gadgets[event.key].dispatch('upload'      , event))
  .listen('upload.progress'        , (event) -> gadgets[event.key].dispatch('uploading'   , event))
  .listen('upload.complete.data'   , (event) ->
    # TODO figure out how get image id control.file_uploaded(event);
    control.file_uploaded event
    gadgets[event.key].dispatch 'uploaded', event
  )


templates =
  modal:
    files_selected: $.jqotec """
        <div class=\"modal\" id=\"selected-modal\">
          <h1><img src="/assets/structure/modal-summary-checkmark.png" /> <*= this.title *></h1>
          <div class=\"content\">
            <h2>
              <div class="call">Como vai querer a maioria delas?</div>
              <div class="choose">Escolha o <u>tamanho</u>, <u>tipo de papel</u> e <u>quantidade de cópias</u> abaixo:</div>
              <div class="note">Note que você pode altera-las individualmente depois.</div>
            </h2>
            <div id=\"defaults-gadget\"></div>
            <div class=\"summary\">
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> <b data-text=\"modal.copies\">1</b> de cada<br />
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> tamanho <b data-text=\"modal.size\">10x15</b><br />
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> papel <b data-text=\"modal.paper\">fosco</b><br />
            </div>
          </div>

          <div class=\"button-group\">
            <*= this.rendered_buttons *>
          </div>
        </div>
      """

$(initialize);