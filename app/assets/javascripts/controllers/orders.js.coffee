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


products        = null
order           = null
shelf           = null
uploader        = null
specifications  = null

kuva.orders = (options) ->
  # TODO pass order details from rails, this must be a instance of recordhot
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
       dropper.overlay.show()
     ).bind('drop', @droped)

     @overlay.element.bind('dragleave', (event) ->
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
      .one('upload.started', (event) ->
        aside.progress.status.text = "Enviando fotos..."
      )
      .on('upload.started', (event) ->
        gadgets(event.key).dispatch('upload', event)
      )
      .on('upload.progressed', (event) ->
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
    setTimeout ->
      order.close()
    , 500 # needed because it was closing before the last upload



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
    document.location = document.location.pathname



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

      # TODO isso tá mto feio!
      # control.photos.create needs a deferred
      d = $.Deferred()
      d.done -> $(window).scroll()
      selection_control.deferreds.push d

      control.photos.create(1).done ->
        copy.recompose();

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
      # aside.summary.add photo


  $.extend that, multiton
  that


# TODO move to another file
selection_control =
  defaults : []
  deferreds: []
  photos   : []

  modal: ->
    count = 0
    selection_control.photos.push []

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
      title       : "Você selecionou <span class=\"amount\"><b data-text=\"modal.amount\"></b> <span data-text=\"modal.amount_label\">foto</span></span>"
      confirm     : ->
        kuva.overlay().close()
        mass.element.find('[rel=tooltip]').tooltip('destroy')
        control.modal.close()
        bus.publish 'files.selection_confirmed'
        $(document.body).removeClass('selecting')
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
    kuva.modal = control.modal


  first_selection_choosed: (event) ->
    bus.pause()
    $.when(order.open(), $('#main-add').slideUp()).then bus.resume


  files_validated: (event) ->
    unless event.valid
      alerty.warn 'Todas fotos selecionadas já haviam sido adicionadas e foram ignoradas.<br><small>Caso queira as mesmas fotos em outro tamanho/papel/etc, duplique-as individualmente.</small>'
      return

    event.invalid && alerty.warn "#{event.invalid} das #{event.valid+event.invalid} fotos selecionadas já haviam sido adicionadas e foram ignoradas.<br><small>Caso queira as mesmas fotos em outro tamanho/papel/etc, duplique-as individualmente.</small>"

    $(document.body).addClass('selecting')
    selection_control.modal()

    # TODO deferred must be stored to be retrieved later by control.create
    $.when(
      (->
        d = $.Deferred()
        bus.one 'files.selected', -> d.resolve()
        d.promise()
      )(),
      (->
        d = $.Deferred()
        bus.one 'files.selection_confirmed', -> d.resolve()
        d.promise()
      )(),
      (->
        # resolved after control.create
        d = $.Deferred()
        d.done -> $(window).scroll()
        selection_control.deferreds.push d
        d.promise()
      )()
    ).then ->

      selected = selection_control.photos.shift()
      defaults = selection_control.defaults.shift()

      count = 0

      for photo in selected
        if !photo.defaulted && !photo.dead
          count++
          photo.defaulted = true

          for name, value of defaults
            # TODO make record support setting of association attributes
            if name.indexOf('_attributes') != -1
              association_name = name.replace '_attributes', ''
              for attribute, value of defaults[name]
                photo[association_name][attribute] = value
            else
              photo[name] = value

      alerty.success "#{count} fotos alteradas."

      # TODO See witch photos have aready been selected and only add those to aside
      aside '#aside'


  file_selected: (event) ->
    file  = event.file
    key   = event.key

    # Create a new gadget and display it
    gadget = gadgets key
    setTimeout ->
      gadgets.pile -> gadget.show()
    , 0

    # Criar uma photo para arquivo selecionado
    gadget.photo = photo = order.photos.build
      border     : false
      count      : 1
      image_id   : null
      margin     : false
      name       : file.name
      product    : control.defaults.product
      product_id : control.defaults.product._id

    gadget.files ||= []
    gadget.files.push file

    # Store photo for later usage
    selection_control.photos[selection_control.photos.length - 1].push photo

    if control.modal and control.modal.amount
      control.modal.amount++
      if control.modal.amount <= 2
        control.modal.amount_label = if control.modal.amount == 1 then "foto" else "fotos"

    # update other interface
    # counters, order price, etc
  files_selected: (event) ->
    # in case of duplicated photos the amount can be 0
    return unless event.amount

    aside.progress.status.total += event.amount

    control.modal.amount = event.amount
    control.modal.amount_label = if control.modal.amount == 1 then "foto" else "fotos"

    # Create photos records
    control.photos.create event.amount

  selection_confirmed: ->
    # TODO change json to a getter to_json
    defaults = control.defaults.photo.json()

    delete defaults.name
    delete defaults.width
    delete defaults.height

    selection_control.defaults.push defaults

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


  first_files_selection: ->
    $(window).on 'beforeunload', -> 'Seu pedido será cancelado!'




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
      .done(@created).fail(@failed).promise()

    created: (response) ->
      ids = response.photo_ids

      for key, gadget of gadgets.all
        photo = gadget.photo

        continue if photo._id?

        gadget.tie ids.shift()
        aside.summary.add photo

        # TODO photo.gadget().unlock()

      selection_control.deferreds.shift().resolve()


    failed: (xhr, status, error) ->
      message  = "control.photos.failed: Failed creating photos. \n"
      message += "Request Message: #{status} - #{error} \n"
      message += "Enviroment: \n"
      message += "order: #{JSON.stringify(order.json())}"
      throw message

  gadget_imploded: ->
    aside.progress.status.total--

  file_uploaded: (event) ->
    aside.progress.status.count++

    photo = gadgets(event.key).photo

    # associate
    photo.image_id = event.data.id

  reader_errored: (event, gadget) ->
    gadget.implode()
    alerty.error "Não conseguimos ler a imagem <a href=\"javascript:$('html,body').animate({scrollTop: #{gadget.element.offset().top}},1000);\">#{gadget.files[0].name}</a>. Este arquivo não será enviado.<br><small>Esta foto não será cobrada.<small>"
    message  = "Reader error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  reader_unknown_type: (event, gadget) ->
    gadget.implode()
    alerty.error "Formato não suportado para <a href=\"javascript:$('html,body').animate({scrollTop: #{gadget.element.offset().top}},1000);\">#{gadget.files[0].name}</a>. Este arquivo não será enviado.<br><small>Esta foto não será cobrada.<small>"
    message  = "Reader unknown type with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  thumbnailer_errored: (event, gadget) ->
    alerty.warn "Não conseguimos gerar a miniatura da imagem <a href=\"javascript:$('html,body').animate({scrollTop: #{gadget.element.offset().top}},1000);\">#{gadget.files[0].name}</a>. No entanto, este arquivo SERÁ enviado."
    message  = "Thumbnailing error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  upload_errored: (event, gadget) ->
    message  = "Upload error with order #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  upload_errored_maximum: (event, gadget) ->
    gadget.implode()
    alerty.error "Não conseguimos enviar a imagem <a href=\"javascript:$('html,body').animate({scrollTop: #{gadget.element.offset().top}},1000);\">#{gadget.files[0].name}</a>.<br><small>Esta foto não será cobrada.<small>"
    message  = "Maximum upload errors reached in #{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    message += "File details: #{JSON.stringify gadget.files[0]} \n"
    throw message

  error_uncaughted: (event, gadget) ->
    message  = "Error uncaughted. Order ##{order._id}. \n"
    message += "Event details: #{JSON.stringify event} \n"
    alerty.error "Ops... aconteceu um erro e ainda não sabemos o motivo.<br><small>Já fomos notificados e vamos resolver logo! Que tal tentar mais uma vez? Se o erro persistir, fale com a gente no chat alí embaixo, por favor!<br><a href=\"javascript: document.location = document.location.pathname\">Clique aqui para recarregar a página e tentar novamente</a>", 0
    kuva.overlay().dynamic().at(document.body)
    $zopim.livechat.window.show() if $zopim?
    throw message

  closed: ->
    aside.progress.status.text = "Concluído!"
    kuva.overlay().dynamic().at(document.body)
    $(window).off 'beforeunload'

    modal
      order: "# #{order.sequence}"
      confirm: ->
        document.location = document.location.pathname
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
  .on('application.initialized'   , control.initialized                                          )
  .one('selection.choosed'        , selection_control.first_selection_choosed                    )
  .on('files.validated'           , selection_control.files_validated                            )
  .on('file.selected'             , selection_control.file_selected                              )
  .on('files.selected'            , selection_control.files_selected                             )
  .one('files.selected'           , selection_control.first_files_selection                      )
  .on('files.selection_confirmed' , selection_control.selection_confirmed                        )
  .one('files.selection_confirmed', selection_control.first_selection_confirmed                  )
  .on('order.opened'              , control.order_opened                                         )
  .on('reader.loadstarted'        , (event) -> gadgets(event.key).dispatch('loadstart'   , event))
  .on('reader.progressed'         , (event) -> gadgets(event.key).dispatch('progress'    , event))
  .on('reader.loadended'          , (event) -> gadgets(event.key).dispatch('loadend'     , event))
  .on('reader.aborted'            , (event) -> gadgets(event.key).dispatch('abort'       , event))
  .on('reader.errored'            , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch('reader_errored', event)
    control.reader_errored event, gadget
  )
  .on('reader.unknown_type'       , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch('reader_unknown_type', event)
    control.reader_unknown_type event, gadget
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
  .on('upload.errored.maximum'      , (event) ->
    gadget = gadgets(event.key)
    gadget.dispatch 'upload_errored_maximum', event
    control.upload_errored_maximum event, gadget
  )
  .on('send.completed'              , control.send_completed                                       )
  .on('order.closed'                , control.closed                                               )
  .on('order.canceled'              , control.cancel_completed                                     )
  .on('error.uncaughted'            , control.error_uncaughted                                     )
  .on('gadget.imploded'              , control.gadget_imploded                                     )


templates =
  modal:
    files_selected: $.jqotec """
        <div class="modal" id="selected-modal">
          <h1><img src="/assets/structure/modal-summary-checkmark.png" /> <*= this.title *></h1>
          <div class="content" data-hidden="modal.content_hidden">
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