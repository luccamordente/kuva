# = require rivets/formatters

@aside = do ->
  aside = (selector = '#aside', photos) ->
    aside.element = $ selector
    summary.initialize(photos)

  item_prototype =
    add: (photo) ->
      throw "aside.item.add: Photo #{photo} already in item #{@product.name}." if photo in photos
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
    change: ->
      if progress.confirmed and progress.status.count == progress.status.total
        bus.publish 'send.completed'

      $('#send-progress .bar').css width: (progress.status.count / progress.status.total * 100) + '%'




  summary = observable.call
    group: (product) ->

      group = @grouped[product.name]

      unless group
        group = @grouped[product.name] = observable.call $.extend
          photos: [],
          product_name: product.name,
          product: product,
          count: 0
        , item_prototype

        group.count = 0

        @items.push group
        @items = @items         # TODO add support to rivets on array bindings

      group
    grouped: {}
    items: []
    total: 0
    initialize: (photos) ->
      @add.apply photos

      # Render element
      aside.element.children('.normal').jqoteapp summary.template, summary
      @element = aside.element.find '#summary'
      view = rivets.bind @element, summary: summary

      @calculate_total()
      @view = view
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
    update_product: (value) ->
      return if @product_id == value

      # TODO Eager load association when
      # product_id changes
      old_product = window.product.find @product_id
      old_item = summary.group old_product
      old_item.remove @ if old_item?

      product = window.product.find value
      item = summary.group product
      item.add @

      summary.calculate_total
    update_count: (value) ->
      item = summary.grouped[@product.name]
      item.count += +value - +@count

      summary.calculate_total() # TODO Only recalculate the changed price


    template: """
      <div id=\"summary\" class=\"faded\">
        <div class=\"items\">
          <div class=\"item\" data-each-item=\"summary.items\">
            <div class=\"block count\" data-text=\"item.count\">0</div>
            <div class=\"block times\">x</div>
            <div class=\"block product\">
              <div class=\"thumb\">
                <img alt=\"Generic Temporary Small Photo Pile\" src=\"http://kuva.dev/assets/generic-temporary-small-photo-pile.png\" />
                <div class=\"name\" data-text=\"item.product_name\"></div>
              </div>
            </div>
          </div>
        </div>

        <div class=\"total\">
          <span class=\"unit\">R$</span>
          <span class=\"count\" data-text=\"summary.total | money\"><*= this.total *></span>
        </div>
      </div>
      """

  aside.summary  = summary
  aside.progress = progress
  aside