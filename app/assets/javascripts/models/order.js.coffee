#= require library/framework/record
#= require models/photo
#= require models/image

order_model = model.call resource: 'order', hasMany: 'images'

@order = (data) ->
  # TODO improve model method support
  associations.call order_model(data)

# TODO Make association a generic method
associations = ->
  @before('save', ->
    image.save() for image in @images
    photo.save() for photo in @photos
  )

  record = @
  mixin_images =
    add: (record) -> @push(@build(record))
    build: (data = {}) ->
      data.order = record
      data.parent_resource = "order"
      data.route = "/orders/#{record._id}/images"
      window.image(data)
    push: Array.prototype.push

  mixin_photos =
    add: (record) -> @push(@build(record))
    build: (data = {}) ->
      data.order = record
      data.parent_resource = "order"
      data.route = "/orders/#{record._id}/photos"
      window.photo(data)
    push: Array.prototype.push


  $.extend(@, images: mixin_images, photos: mixin_photos)

open = ->
  # requisição para abrir ordem

opened = ->
  # salvar dados da ordem
  # dispachar evento de abertura de ordem, bus.publish(order.opened)

errored = ->
  # dispachar evento de falha na abertura de ordem, bus.publish(order.opened)

# close, closed
  # o método close é bem ligado com a interface, melhor fazer depois