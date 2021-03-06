# = require rivets/formatters

@aside = do ->
  aside = (selector = '#aside', photos) ->
    aside.element = $ selector
    summary.initialize(photos)
    observations.initialize()

  item_prototype =
    add: (photo) ->
      throw "aside.item.add: Photo #{photo} already in item #{@product.name}." if photo in @photos
      @count += ~~photo.count
      @photos.push photo
    remove: (photo) ->
      if photo in @photos
        @count -= ~~photo.count
        @photos.splice @photos.indexOf(photo), 1
      else
        throw "aside.item.remove: Photo '#{photo}' not found to remove in #{@photos} of item #{@product.name}"

  progress =

    status: observable.call
      count: 0
      total: 0
      text : "Preparando fotos..."
    change: (prop, value, old_value) ->
      count = if prop == 'count' then value else progress.status.count
      total = if prop == 'total' then value else progress.status.total

      $('#send-progress .bar').css width: (count / total * 100) + '%'

      if progress.confirmed and count == total
        bus.publish 'send.completed'
        progress.status.text = "Fechando pedido..."


  observations = observable.call
    editing: false

    initialize: ->
      return if @initialized

      @order = kuva.order

      @element = aside.element.find '#observations'
      @field   = @element.find 'textarea'
      @view = rivets.bind @element,
        editor: observations
        order : kuva.order

      @initialized = true

    check_commit: (event) ->
      if event.which == 13 # ENTER
        @field.change()
        $(document.body).focus()

    formatted_observations: ->
      @sanitized_observations()

    sanitized_observations: ->
      (@order.observations || "").trim()

    toggle: ->
      @editing = !@editing
      @field.focus() if @editing

    empty : -> !@editing && !@sanitized_observations()
    filled: -> !@editing &&  @sanitized_observations()


  summary = observable.call
    group: (product) ->

      group = @grouped[product.name]

      unless group
        group = @grouped[product.name] = observable.call $.extend
          photos      : [],
          product_name: product.name,
          product     : product,
          count       : 0
          show        : false
        , item_prototype

        group.count = 0

        @items.push group
        # @items = @items         # TODO add support to rivets on array bindings

      group
    grouped: {}
    items: []
    total: 0
    initialize: (photos) ->
      @add.apply @, photos

      return if @initialized;

      # Render element
      aside.element.children('.summary-placeholder').jqoteapp summary.template, summary
      @element = aside.element.find '#summary'
      view = rivets.bind @element, summary: summary

      @calculate_total()
      @view = view
      @initialized = true

    add: (photos...) ->
       # Group photos by size on @groups
      for photo in photos
        @group(photo.product).add photo

        # Remember to update photo on changes
        photo.subscribe 'count', @update_count
        photo.subscribe 'product_id', @update_product

    calculate_total: ->
      total = 0

      for product_name, item of @grouped
        total += item.count * +item.product.price

      @total = total
    update_product: (prop, product_id, old_product_id) ->
      return if old_product_id == product_id

      # TODO Eager load association when
      # product_id changes
      old_product = window.product.find old_product_id
      old_item = summary.group old_product
      old_item.remove @
      old_item.show = old_item.count > 0

      product = window.product.find product_id
      item = summary.group product
      item.add @
      item.show = item.count > 0

      summary.calculate_total()
    update_count: (prop, count, old_count) ->
      item = summary.grouped[@product.name]
      item.count += +count - ~~old_count
      item.show   = item.count > 0

      summary.calculate_total() # TODO Only recalculate the changed price


    template: """
      <div id=\"summary\" class=\"faded\">
        <div class=\"items\">
          <div class=\"item\" data-each-item=\"summary.items\" data-show="item.show">
            <div class=\"block count\" data-text=\"item.count\">0</div>
            <div class=\"block times\">x</div>
            <div class=\"block product\">
              <div class=\"block name\" data-text=\"item.product_name\"></div>
              <img class=\"block\" alt=\"Generic Temporary Small Photo Pile\" src=\"/assets/generic-temporary-small-photo-pile.png\" />
            </div>
          </div>
        </div>

        <div class=\"total\">
          <span class=\"unit\">R$</span>
          <span class=\"count\" data-text=\"summary.total | money\"><*= this.total *></span>
        </div>
      </div>
      """

  aside.show = (complete) ->
    # TODO Use animations only when css3 animations
    # is not possible
    # Animate sidebar
    $('#aside').animate {width: '9em', padding: '1em'}, complete: complete

  aside.hide = ->

    $('#aside').css width: '0', padding: '0'  # TODO Move to aside component
    $('#main').css paddingRight: 0
    $('#main-add').width '100%'

  aside.summary  = summary
  aside.progress = progress
  aside