#= require controllers/kuva
#= require ui/modal
#= require ui/overlay
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

reader          = lib.reader()
selected_photos = []                     # Proposital array for automatic counting of length


products        = null
order           = null
shelf           = null
uploader        = null
specifications  = null

kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of record
  order                    ||= window.order(options.order)
  control.defaults.product ||= window.product(options.default_product)
  specifications           ||= window.specification(options.specifications)
  kuva.orders.products       = products = window.product.cache = options.products
  window.gadgets = gadgets

  kuva.order = order


# TODO Move droppable to a component
dropper =
  dragover: (event) -> false
  droped  : (event) ->
    # avoids any drop
    # TODO fix drag and drop
    dropper.overlay.hide();
    return false

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

send =
  clicked: ->
    kuva.overlay().dynamic().at(document.body)
    $('#end-confirmation').fadeIn()
  ignored: ->
    kuva.overlay().close()
    $('#end-confirmation').fadeOut()
  confirmed: ->
    progress = aside.progress
    progress.confirmed = true

    bus
      .on('upload.start', (event) ->
        aside.progress.status.text = "Enviando fotos..."
        bus.off 'upload.start', @callee
      )
      .on('upload.start', (event) ->
        gadgets(event.key).dispatch('upload', event)
      )
      .on('upload.progress', (event) ->
        gadget = gadgets event.key
        gadget.dispatch('upload', event) unless gadget.uploading
        gadget.dispatch('uploading', event)
      )

    rivets.bind $('#aside .sending'), progress: observable.call progress.status
    progress.status.subscribe 'count', progress.change
    progress.status.publish()

    $(document.body).addClass('sending').removeClass('normal')
    $('#gadgets .gadget').addClass('uploading')

    send.ignored()
  completed: ->
    order.close()



cancel =

  clicked: ->
    kuva.overlay().dynamic().at(document.body)
    cancel.modal = modal
      cancel: ->
        kuva.overlay.close()
        cancel.modal.close()
      confirm: ->
        $(window).off 'beforeunload'
        order.cancel()
      ,
      [
        'confirm.danger => Sim<small>, quero cancelar meu pedido</small>',
        'cancel => Não<small>, quero voltar</small>'
      ],
      template: templates.modal.cancel_order, minWidth: 500, minHeight: 500

  completed: ->
    document.location = document.location



# module
gadgets = do ->
  that = (key, options = {}) ->
    instances[key] ||= gadget null, $.extend(options, key: key)

  instances = {}

  multiton =
    id: 0
    key: -> multiton.id++
    all: instances
    queue: []
    defer: $.when()
    next: ->
      if multiton.defer.state() == 'resolved' && multiton.queue.length > 0
        task = multiton.queue.shift()
        multiton.defer = task()
        multiton.queue.length && multiton.defer.done(multiton.next)
    pile: (task) ->
      @queue.push task
      @next()
    duplicated: (copy) ->
      key = multiton.key()
      copy.key = key
      instances[key] = copy
      photo = copy.photo

      # TODO automatcally eager load
      # product when product_id is set
      photo.product = product.find photo.product_id unless photo.product

      # Create next photo
      control.photos.create(1)
      copy.show()

      original = this

      # original.listen 'uploading', (event) ->
      #   if copy.key == event.key
      #     gadget.handlers.uploading.call copy, event

      original.listen 'uploaded', (event) ->
        if !copy.uploaded
          gadget.handlers.uploaded.call copy, event

          unless copy.photo.image_id?
            photo.image_id = event.data.id
            photo.save()

      # Display fotos in summary
      aside.summary.add photo


  $.extend that, multiton
  that

control =
  defaults:
    photo: undefined
    product: undefined
  modal: undefined

  initialized: ->
    $('#initializing').fadeOut 'fast', ->
      $('#main-add').fadeIn 2000
      shelf.overlay 'button'


  order_opened: (event) ->
    uploader = window.uploader
      url: "/pedidos/#{order._id}/images/"
      data:
        order_id: order._id

  first_selection_choosed: (event) ->
    bus.pause()
    $.when(order.open(), $('#main-add').slideUp()).then bus.resume

    bus.off 'selection.choosed', arguments.callee

  file_selected: (event) ->
    file  = event.file
    key   = event.key
    count = 0

    # Create a new gadget and display it
    gadget = gadgets key
    gadgets.pile -> gadget.show()

    # Criar uma photo para arquivo selecionado
    gadget.photo = photo = order.photos.build
      name       : file.name
      border     : false
      margin     : false
      count      : 1
      product    : control.defaults.product
      product_id : control.defaults.product._id

    gadget.files ||= []
    gadget.files.push file

    # Store photo for later usage
    selected_photos.push photo

    # update other interface
    # counters, order price, etc
  files_selected: (event) ->
    aside.progress.status.total += event.amount

    # Create default model
    control.defaults.photo = photo = order.photos.build
        name          : 'Foto Padrão'
        border        : false
        margin        : false
        count         : 1
        default       : true
        product       : control.defaults.product
        product_id    : control.defaults.product._id
        specification : window.specification({ paper: 'glossy' })
        width         : 188
        height        : 250


    # TODO create a deferred
    buttons = ['confirm.success => Próxima etapa: <small>alteração individual</small>']

    mass = gadget '#defaults-gadget',
      data:
        source: kuva.service.url + '/assets/structure/generic-temporary-gadget-photo.jpg'
        title : "Foto de exemplo"

    assigns =
      title       : "Você selecionou <span class=\"amount\"><b data-text=\"modal.amount\">#{event.amount}</b> <span data-text=\"modal.amount_label\">foto</span></span>"
      confirm     : ->
        kuva.overlay().close()
        mass.element.find('[rel=tooltip]').tooltip('destroy')
        control.modal.close()
        bus.publish 'files.selection_confirmed'
      amount      : 1
      amount_label: 'foto'
      copies      : '1 cópia'
      size        : photo.size || '10x15'
      paper       : 'Brilhante'
      border      : false
      margin      : false
      product     : null
      product_id  : null

    # Display modal and gadget
    kuva.overlay().dynamic().at(document.body)
    confirm = modal assigns, buttons, template: templates.modal.files_selected, minWidth: 950, minHeight: 680
    mass.photo = photo
    shown = mass.show()

    mass.dispatch 'loadend', photo

    # Forward photo updates to resume
    # TODO Add support to extended keypaths to observable
    photo.subscribe 'count', (prop, count, old_count) ->

      confirm.copies = if +count
        word = 'cópia'
        word += 's' if +count > 1
        "#{count} #{word}"
      else
        'nenhuma cópia'

    photo.specification.subscribe 'paper', (prop, paper, old_paper) ->
      confirm.paper = specification.paper[paper]

    photo.subscribe 'product_id', (prop, product_id, old_product_id) ->
      confirm.size = product.find(product_id).name

    photo.subscribe 'border', (prop, border, old_border) ->
      confirm.border = border

    photo.subscribe 'margin', (prop, margin, old_margin) ->
      confirm.margin = margin

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
      if control.modal.amount <= 2
        control.modal.amount_label = if control.modal.amount == 1 then "foto" else "fotos"
    , 30

    # Create photos records
    control.photos.create event.amount

    # TODO See witch photos have aready been selected and only add those to aside
    aside '#aside', selected_photos

  selection_confirmed: ->
    # TODO change json to a getter to_json
    defaults = control.defaults.photo.json()

    delete defaults.name
    delete defaults.width
    delete defaults.height

    for photo in selected_photos
      unless photo.defaulted
        photo.defaulted = true

        for name, value of defaults
          # TODO make record support setting of association attributes
          if name.indexOf('_attributes') != -1
            association_name = name.replace '_attributes', ''
            for attribute, value of defaults[name]
              photo[association_name][attribute] = value
          else
            photo[name] = value

    # Empty selection
    selected_photos = []
    false

  first_selection_confirmed: ->
    # Display aside and fix main app container
    aside.show ->
      shelf.overlay 'buttonzin'

      # Use css animations when available
      main = $ '#main'
      main.animate padding: '0 11em 0 0'

      setTimeout ->
        main.css 'width', main.width() - 10
        setTimeout ->
          main.width 'auto'
        , 20
      , 100


    # Prevent future calls for this event
    bus.off 'files.selection_confirmed', arguments.callee

  first_files_selection: ->
    bus.off 'files.selected', arguments.callee
    $(window).on 'beforeunload', -> 'Seu pedido será cancelado!'

  thumbnailed: (event) ->
    # todas miniaturas construidas
    uploader.upload {}

  photos:
    create: (count) ->
      order.photos.post
        count: count
        photo:
          count     : 1
          product_id: control.defaults.product._id
          specification_attributes:
            paper: 'glossy'
      .done(@created).fail(@failed)
      true

    created: (response) ->
      ids = response.photo_ids

      setTimeout ->
        for key, gadget of gadgets.all
          photo = gadget.photo

          continue if photo._id?

          gadget.tie ids.shift()

          # TODO photo.gadget().unlock()
      , 0


    failed: (xhr, status, error) ->
      message  = "control.photos.failed: Failed creating photos. \n"
      message += "Request Message: #{status} - #{error} \n"
      message += "Enviroment: \n"
      message += "order: #{JSON.stringify(order.json())}"
      throw message

  file_uploaded: (event) ->
    aside.progress.status.count++

    photo = gadgets(event.key).photo

    # associate and save image
    photo.image_id = event.data.id
    photo.save()

  reader_errored: (event, gadget) ->
    aside.progress.status.total--
    message  = "Reader error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  thumbnailer_errored: (event, gadget) ->
    message  = "Thumbnailing error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  upload_errored: (event, gadget) ->
    message  = "Upload error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  error_uncaughted: (event, gadget) ->
    message  = "Error uncaughted. Order ##{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    alert "Ops... aconteceu um erro e ainda não sabemos o motivo. Já fomos notificados e vamos resolver logo! Que tal tentar mais uma vez? Se o erro persistir, fale com a gente no chat alí embaixo, por favor!"
    throw message

  closed: ->
    aside.progress.status.text = "Concluído!"
    kuva.overlay().dynamic().at(document.body)
    $(window).off 'beforeunload'

    modal
      order: "# #{order.sequence}"
      confirm: ->
        document.location = document.location
      ,
      ['confirm.success => Concluir'],
      template: templates.modal.order_closed, minWidth: 550, minHeight: 500



  send_clicked  : send.clicked
  send_ignored  : send.ignored
  send_confirmed: send.confirmed
  send_completed: send.completed

  cancel_clicked  : cancel.clicked
  cancel_completed: cancel.completed


# Module methods
initialize = ->

  $('#send-button' ).bind 'click', control.send_clicked
  $('#ignore-send' ).bind 'click', control.send_ignored
  $('#confirm-send').bind 'click', control.send_confirmed
  $('#cancel'      ).bind 'click', control.cancel_clicked

  # Hide sidebar
  aside.hide()

  shelf = kuva.shelf('#add-more','#add-button', 'object:last')

  gadget.listen 'duplicated', gadgets.duplicated

  # Setup drag and drop
  dropper.overlay.element = $('#overlay')
  reader.read.as 'dataURL'
  reader.onloadend = dropper.readed
  reader.onerror = dropper.errored
  dropper.bind()

  # TODO Better listeners interface, put key on event listener
  #      and move inside gadget initializer
  bus
  .on('application.initialized'  , control.initialized                                          )
  .on('selection.choosed'        , control.first_selection_choosed                              )
  .on('file.selected'            , control.file_selected                                        )
  .on('files.selected'           , control.files_selected                                       )
  .on('files.selected'           , control.first_files_selection                                )
  .on('files.selection_confirmed', control.selection_confirmed                                  )
  .on('files.selection_confirmed', control.first_selection_confirmed                            )
  .on('order.opened'             , control.order_opened                                         )
  .on('reader.loadstarted'       , (event) -> gadgets(event.key).dispatch('loadstart'   , event))
  .on('reader.progressed'        , (event) -> gadgets(event.key).dispatch('progress'    , event))
  .on('reader.loadended'         , (event) -> gadgets(event.key).dispatch('loadend'     , event))
  .on('reader.aborted'           , (event) -> gadgets(event.key).dispatch('abort'       , event))
  .on('reader.errored'           , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch('reader_errored', event)
    control.reader_errored event, gadget
  )
  # TODO Replace with a beautiful image
  .on('thumbnailer.corrupted'       , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch('thumbnailer_errored', event)
    control.thumbnailer_errored event, gadget
  )
  .on('thumbnailer.progressed'      , (event) -> gadgets(event.key).dispatch('thumbnailing', event))
  .on('thumbnailer.encoded'         , (event) -> gadgets(event.key).dispatch('encoding'    , event))
  .on('thumbnailer.thumbnailed'     , (event) ->
    gadget = gadgets event.key
    gadget.dispatch 'thumbnailed', event
  )
  .on('thumbnailer.finished'        , control.thumbnailed                                          )
  .on('thumbnailer.errored'         , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch('thumbnailer_errored', event)
    control.thumbnailer_errored event, gadget
  )
  .on('upload.completed.data'       , (event) ->
    # TODO figure out how get image id control.file_uploaded(event);
    gadgets(event.key).dispatch 'uploaded', event
    control.file_uploaded event
  )
  .on('upload.errored'              , (event) ->
    gadget = gadgets(event.key)
    # TODO deal with upload errors on gadgets
    # gadget.dispatch('upload_errored', event)
    control.upload_errored event, gadget
  )
  .on('send.completed'              , control.send_completed                                       )
  .on('order.closed'                , control.closed                                               )
  .on('order.canceled'              , control.cancel_completed                                     )
  .on('error.uncaughted'            , control.error_uncaughted                                     )


templates =
  modal:
    files_selected: $.jqotec """
        <div class="modal" id="selected-modal">
          <h1><img src="/assets/structure/modal-summary-checkmark.png" /> <*= this.title *></h1>
          <div class="content">
            <h2>
              <!--div class="call">Como vai querer a maioria delas?</div-->
              <div class="choose">Escolha o tamanho, tipo de papel e quantidade de cópias abaixo para todas as fotos. </div>
              <div class="note">Na etapa seguinte você poderá fazer alterações individuais.</div>
              <!--div class="note">Na próxima etapa você poderá fazer alterações individuais.</div-->
            </h2>
            <div id="defaults-gadget"></div>
            <div class="summary">
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> <b data-text="modal.copies">1</b> de cada<br />
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> tamanho <b data-text="modal.size">10x15</b><br />
              <img src="/assets/structure/modal-summary-small-checkmark.png" /> papel <b data-text="modal.paper">fosco</b><br />
              <span data-show="modal.margin"><img src="/assets/structure/modal-summary-small-checkmark.png" /> <b>margem</b><br /></span>
              <span data-show="modal.border"><img src="/assets/structure/modal-summary-small-checkmark.png" /> <b>sem corte</b><br /></span>
            </div>
          </div>

          <div class="button-group">
            <*= this.rendered_buttons *>
          </div>
        </div>
      """
    order_closed: $.jqotec """
        <div class="modal simplemodal-data" id="sent-modal" style="display: block; ">
          <h1>
            <img src="/assets/structure/modal-summary-checkmark.png">
            Suas fotos foram enviadas e já estão conosco!
          </h1>
          <div class="content" style="width: 550px;">
            <h2>Em até 1 hora* suas fotos estarão prontas para você buscar, aqui no Pedro Cine Foto.</h2>
            <div class="note">
              <b>Lembre-se:</b>
              o pagamento só será feito quando você vier buscá-las.
              <br /><br />
              <span class="observations">
                * O prazo de 1 hora para prepararmos suas fotos só é válido para o horário comercial (segunda a sexta de 8:00 às 19:00 e sábado de 8:00 às 13:00).Caso seu pedido tenha sido fechado fora desse horário, este ficará pronto às 9:00 do próximo dia comercial.
              </span>
            </div>
            <div class="order"><*= this.order *></div>
          </div>
          <div class="button-group">
            <span class="help">
              Tem alguma dúvida?
              <a href="javascript:$zopim.livechat.window.show();">Clique aqui para falar com a gente.</a>
            </span>
            <a class="button confirm success" data-on-click="modal.confirm">
              CONCLUIR
            </a>
          </div>
        </div>
      """
    cancel_order:  $.jqotec """
        <div class="modal simplemodal-data" id="sent-modal" style="display: block; ">
          <div class="content">
            Quer mesmo cancelar seu pedido?
          </div>
          <div class="button-group">
            <*= this.rendered_buttons.join(' ') *>
          </div>
        </div>
      """

$(initialize);