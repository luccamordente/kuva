#= require library/record

@order = (data) ->
  # TODO improve model method support
  associations.call(record.call($.extend(path: 'orders', resource: 'order', data)))

# TODO Make association a generic method
associations = ( ->
  @before('save', ->
    image.save() for image in @images
    photo.save() for photo in @photos
  )

  model = @
  mixin_images =
    add: -> @push(@build.call(@, arguments))
    build: (data) ->
     data.order = model
     data.parent_resource = "order"
     image(data)
    push: Array.prototype.push

  mixin_photos =
    add: -> @push(@build.call(@, arguments))
    build: (data) ->
     data.order = model
     data.parent_resource = "order"
     photo(data)
    push: Array.prototype.push


  -> $.extend(@, images: mixin_images, photos: mixin_photos)
)

open = ->
  # requisição para abrir ordem

opened = ->
  # salvar dados da ordem
  # dispachar evento de abertura de ordem, bus.publish(order.opened)

errored ->
  # dispachar evento de falha na abertura de ordem, bus.publish(order.opened)

# close, closed
  # o método close é bem ligado com a interface, melhor fazer depois