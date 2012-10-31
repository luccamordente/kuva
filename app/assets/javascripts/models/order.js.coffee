#= require library/framework/record
#= require models/photo
#= require models/image

order_model = model.call resource: 'order', has_many: 'images', route: 'pedidos'

@order = (data) ->
  # TODO improve model method support
  openable.call cancelable.call closeable.call associations.call order_model data

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


openable = ->
  @open = (callback) ->
    $.ajax
      url: "#{@route}"
      type: "POST"
      success: (params...) ->
        opened.apply @, params
        callback.call @ if callback?
      statusCode:
        422: unprocessable
        500: error
      context: @

  opened = (response) ->
    @_id      = response.id
    @sequence = response.sequence
    bus.publish 'order.opened'

  unprocessable = (xhr, status) ->
    alert "Erro ao abrir pedido!"
    throw "order.open.unprocessable: {id: #{@_id}} Error '#{status}' processing request"

  error = (xhr, status) ->
    alert "Erro ao accessar o servidor."
    throw "order.open.error: {id: #{@_id}} Error '#{status}' processing request"

  @

errored = ->
  # dispachar evento de falha na abertura de ordem, bus.publish(order.opened)

closeable = ->
  @close = ->
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
    alert "Erro ao fechar pedido!"
    throw "order.close.unprocessable: {id: #{@_id}} Error '#{status}' processing request"

  error = (xhr, status) ->
    alert "Erro ao accessar o servidor."
    throw "order.close.error: {id: #{@_id}} Error '#{status}' processing request"

  @

cancelable = ->
  @cancel = ->
    $.ajax
      url: "#{@route}/#{@_id}/cancel"
      type: "POST"
      success: canceled
      statusCode:
        422: unprocessable
        500: error
      context: @

  canceled = (response) ->
    bus.publish 'order.canceled'

  unprocessable = (xhr, status) ->
    alert "Erro ao cancelar pedido!"
    throw "order.cancel.unprocessable: {id: #{@_id}} Error '#{status}' processing request"

  error = (xhr, status) ->
    alert "Erro ao accessar o servidor."
    throw "order.cancel.error: {id: #{@_id}} Error '#{status}' processing request"

  @