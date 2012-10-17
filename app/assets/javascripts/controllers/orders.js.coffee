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

reader         = lib.reader()
photos         = []                     # Proposital array for automatic counting of length


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
  window.gadgets = gadgets

  window.domo = uploader = window.uploader
    url: "/pedidos/#{order._id}/images/"
    data:
      order_id: order._id

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
    progress.status.count = progress.status.count

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
      confirm: -> order.cancel(),
      [
        'confirm.danger => Sim<small>, quero cancelar meu pedido</small>',
        'cancel => Não<small>, quero voltar</small>'
      ],
      template: templates.modal.cancel_order, minWidth: 500, minHeight: 500

  completed: ->
    document.location = document.location



# module
gadgets = do ->
  that = (key, options) ->
    instances[key] ||= gadget(options)

  instances = {}

  multiton =
    id: 0
    key: -> multiton.id++
    all: instances
    duplicated: (copy) ->
      instances[multiton.key()] = copy
      photo = copy.photo

      # TODO automatcally eager load
      # product when product_id is set
      photo.product = product.find photo.product_id unless photo.product

      # Create next photo
      control.photos.create(1)
      copy.show()

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


  file_selected: (event) ->
    file  = event.file
    key   = event.key
    count = 0

    # Create a new gadget and display it
    gadget = gadgets(key).show()

    gadget.listen 'duplicated', gadgets.duplicated

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
    aside.progress.status.total += event.amount

    # Create default model
    control.defaults.photo = photo = order.photos.build
        name          : 'Foto Padrão'
        count         : 1
        default       : true
        product       : control.defaults.product
        product_id    : control.defaults.product._id
        specification : window.specification({ paper: 'glossy' })
        width         : 320
        height        : 480


    # TODO create a deferred
    buttons = ['confirm.success => Próxima etapa: <small>alteração individual</small>']

    mass = gadget '#defaults-gadget',
      data:
        source: kuva.service.url + '/assets/structure/generic-temporary-gadget-photo.jpg'
        title : "Foto de exemplo"

    assigns =
      title       : "Você selecionou <span class=\"amount\"><b data-text=\"modal.amount\">#{event.amount}</b> <span data-text=\"modal.amount_label\">foto</span></span>"
      confirm     : ->
        bus.publish 'files.selection_confirmed'
        kuva.overlay().close()
        mass.element.find('[rel=tooltip]').tooltip('destroy')
      amount      : 1
      copies      : '1 cópia'
      size        : photo.size || '10x15'
      paper       : 'Brilhante',

    # Display modal and gadget
    kuva.overlay().dynamic().at(document.body)
    confirm = modal assigns, buttons, template: templates.modal.files_selected, minWidth: 780, minHeight: 680
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

    photo.specification.subscribe 'paper', (paper) ->
      confirm.paper = specification.paper[paper]

    photo.subscribe 'product_id', (product_id) ->
      confirm.size = product.find(product_id).name

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

    aside('#aside', photos);

  selection_confirmed: ->
    aside.show()

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

  first_selection_confirmed: ->
    shelf.overlay 'buttonzin'
    bus.off 'files.selection_confirmed', @callee

  first_files_selection: ->
    $('#main-add').slideUp()
    bus.off 'files.selected', @callee

  thumbnailed: (event) ->
    # todas miniaturas construidas
    for key, gadget of gadgets.all
      break

    gadget.files && uploader.upload gadget.files[gadget.files.length - 1]
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

      for key, gadget of gadgets.all
        photo = gadget.photo

        continue if photo._id?

        gadget.tie ids.shift()

        # TODO photo.gadget().unlock()


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
  closed: ->
    aside.progress.status.text = "Concluído!"
    kuva.overlay().dynamic().at(document.body)
    modal
      order: order._id.substr 0, 8
      confirm: -> document.location = document.location,
      ['confirm.success => Concluir'],
      template: templates.modal.order_closed, minWidth: 590, minHeight: 500



  send_clicked  : send.clicked
  send_ignored  : send.ignored
  send_confirmed: send.confirmed
  send_completed: send.completed

  cancel_clicked  : cancel.clicked
  cancel_completed: cancel.completed


# Module methods
initialize = ->

  $(window).on 'beforeunload', -> 'Seu pedido será cancelado!'

  $('#send-button' ).bind 'click', control.send_clicked
  $('#ignore-send' ).bind 'click', control.send_ignored
  $('#confirm-send').bind 'click', control.send_confirmed
  $('#cancel'      ).bind 'click', control.cancel_clicked

  # Hide sidebar
  aside.hide()

  shelf = kuva.shelf('#add-more','#add-button', 'object:last')

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
  .on('file.selected'            , control.file_selected                                        )
  .on('files.selected'           , control.files_selected                                       )
  .on('files.selected'           , control.first_files_selection                                )
  .on('files.selection_confirmed', control.selection_confirmed                                  )
  .on('files.selection_confirmed', control.first_selection_confirmed                            )
  .on('reader.loadstart'         , (event) -> gadgets(event.key).dispatch('loadstart'   , event))
  .on('reader.progress'          , (event) -> gadgets(event.key).dispatch('progress'    , event))
  .on('reader.loadend'           , (event) -> gadgets(event.key).dispatch('loadend'     , event))
  .on('reader.abort'             , (event) -> gadgets(event.key).dispatch('abort'       , event))
  .on('thumbnailer.progress'     , (event) -> gadgets(event.key).dispatch('thumbnailing', event))
  .on('thumbnailer.encoding'     , (event) -> gadgets(event.key).dispatch('encoding'    , event))
  .on('thumbnailer.thumbnailed'  , (event) ->
    gadget = gadgets event.key
    gadget.dispatch 'thumbnailed', event
  )
  .on('thumbnailer.finished'     , control.thumbnailed                                          )
  .on('upload.complete.data'     , (event) ->
    # TODO figure out how get image id control.file_uploaded(event);
    control.file_uploaded event
    gadgets(event.key).dispatch 'uploaded', event
  )
  .on('send.completed'           , control.send_completed                                       )
  .on('order.closed'             , control.closed                                               )
  .on('order.canceled'           , control.cancel_completed                                     )


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
          <div class="content">
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