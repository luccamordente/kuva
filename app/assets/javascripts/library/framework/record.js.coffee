#= require library/framework/advisable

# private methods
rest =
  put: ->
    rest.request.call @, "#{@path}/#{@id}" || "/#{@resource}/#{@id}"
  post: ->
    rest.request.call @, @path || "/#{@resource}"
  request: (url) ->
    data = {}
    data[@resource] = @json

    $.ajax
      url: url
      data: data
      success: @saved
      error: @failed

initialize_resource = ->
  if @parent_resource
    @["#{@parent_resource}_id}"] = @[@parent_resource].id if @[@parent_resource]
    @path = @[@parent_resource].path + '/' + @["#{@parent_resource}_id}"] unless @path


@model = do -> # mixin
  mixin = ->
    create: (mixed) ->
      # if mixed == array
      #  bulk create multiple itens

  instantiate = (data) ->
    data.resource ||= @resource
    data.parent_resource ||= @parent_resource
    record.call(data)

  ->
    $.extend(@, mixin)
    $.proxy(instantiate, @)

@record = do -> # mixin
  mixin =
    save: ->
      rest[if @id then 'post' else 'put'].call @
    saved: ->
      # parsear resposta do servidor e popular dados no modelo atual
      # tinha pensado em botar as propriedades no modelo mermo, sem criar um "data"
      # dispatchar evento de registro salvo, usando o nome do resource
    json: ->
      json[name] = value for name, value of this when value isnt Function
      json

  (data) ->
    console.error "Mixin called incorrectly, call mixin with call method: record.call(object, data)" if @ == window
    initialize_resource.call(@)
    advisable.call(@)
    $.extend(@, mixin, data)


# @association = ()