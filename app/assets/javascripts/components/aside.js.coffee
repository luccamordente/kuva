# = require rivets/formatters

@aside = do ->
  aside = (selector = '#aside', photos) ->
    aside.element = $ selector
    summary.initialize(photos)

  item =
    count: ->
      total = 0
      for photo in @photos
        total += ~~photo.count

      total

  summary = observable.call
    grouped: {}
    items: []
    total: 0
    initialize: (photos) ->
      # Group photos by size on @lines
      for photo in photos
        unless @grouped[photo.product.name]
          @grouped[photo.product.name] = observable.call $.extend photos: [], product_name: photo.product.name, product: photo.product, item

        current_item = @grouped[photo.product.name]
        current_item.photos.push photo

      # Add lines to view
      for product_name, current_item of @grouped
        @total += current_item.count() * ~~current_item.product.price
        @items.push current_item

      # Render element
      aside.element.children('.normal').jqoteapp summary.template, summary
      @element = aside.element.find '#summary'
      view = rivets.bind @element, summary: summary

      window.mafagafo = summary
      for photo in photos
        photo.subscribe 'count', view.build
        photo.subscribe 'product', view.build

      @view = view
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
  aside