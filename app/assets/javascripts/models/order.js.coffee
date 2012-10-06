#= require library/framework/record
#= require models/photo
#= require models/image

order_model = model.call resource: 'order', has_many: 'images', route: 'pedidos'

@order = (data) ->
  # TODO improve model method support
  closeable.call associations.call order_model(data)

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
      data.route = "/pedidos/#{record._id}/images"
      window.image(data)
    push: Array.prototype.push

  mixin_photos =
    add: (record) -> @push(@build(record))
    build: (data = {}) ->
      data.order = record
      data.parent_resource = "order"
      data.route = "/pedidos/#{record._id}/photos"
      photo = window.photo(data)
    push: Array.prototype.push


  $.extend(@, images: mixin_images, photos: mixin_photos)

open = ->
  # requisição para abrir ordem

opened = ->
  # salvar dados da ordem
  # dispachar evento de abertura de ordem, bus.publish(order.opened)

errored = ->
  # dispachar evento de falha na abertura de ordem, bus.publish(order.opened)

closeable = ->
  @close = (response) ->
    $.ajax
      url: "#{@route}/#{@_id}/close"
      type: "POST"
      success: closed
      statusCode:
        422: unprocessable
        500: error
      context: @

  closed = (response) ->
    bus.publish 'order.closed'

  unprocessable = (xhr, status) ->
    alert "Erro ao fechar pedido"
    throw "order.unprocessable: {id: #{@_id}} Error '#{status}' processing request"

  error = (xhr, status) ->
    alert "Erro ao accessar o servidor."
    throw "order.error: {id: #{@_id}} Error '#{status}' processing request"

  @

closed = ->

cancel = ->

canceled = ->