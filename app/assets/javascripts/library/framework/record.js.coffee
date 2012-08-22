#= require library/framework/advisable

# private methods
rest =
  put: ->
    rest.request.call @, 'put', "#{@route}/#{@_id}"
  post: ->
    rest.request.call @, 'post', @route
  request: (method, url) ->
    data = {}
    data[@resource] = @json()

    $.ajax
      url: url
      data: data
      type: method
      error: @failed
      success: @saved

pluralize = (word) ->
  return word + 's'

initialize_resource = ->
  # TODO route parsing
  @route = "/" + @route if @route and @route.indexOf('/') != 0

  # Set parent attribute and default nested route
  if @parent_resource
    @["#{@parent_resource}_id"] = @[@parent_resource]._id if @[@parent_resource]

    # TODO Support route parsing, and change route to /parents/:id/childrens
    if not @route and @["#{@parent_resource}_id"]
      @route = '/' + pluralize(@parent_resource) + '/' + @["#{@parent_resource}_id"] + '/' + pluralize(@resource)

  unless @route
    @route = '/' + pluralize @resource

# TODO support other type of associations
@model = do -> # mixin
  modelable =
    create: (mixed) ->
      # if mixed == array
      #  bulk create multiple itens

  initialize_record = (data = {resource: @resource, parent_resource: @parent_resource}) ->
    data.resource ||= @resource
    data.parent_resource ||= @parent_resource
    data.route ||= @route
    record.call $.extend data, @record # TODO remove @record from outside scop

  mixer = ->
    mixer.stale = true unless mixer.stale # Prevent model changes


    instance = $.proxy initialize_record, @
    initialize_resource.call(@)
    $.extend instance, $.extend true, @, modelable

  mixer.mix = (object) ->
    console.error "Trying to change model mixin with", object, "but model already used.\nCheck your configuration order" if @stale
    $.extend true, modelable, object

  mixer

@record = do -> # mixin
  mixin =
    save: ->
      rest[if @_id then 'put' else 'post'].call @
    saved: ->
      # parsear resposta do servidor e popular dados no modelo atual
      # tinha pensado em botar as propriedades no modelo mermo, sem criar um "data"
      # dispatchar evento de registro salvo, usando o nome do resource
    json: ->
      json = {}

      for name, value of @ when $.type(value) isnt 'function' and $.type(value) isnt 'object'
        json[name] = value

      # Remove model reserved words
      delete json.resource
      delete json.parent_resource

      json

  (data) ->
    console.error "Mixin called incorrectly, call mixin with call method: record.call(object, data)" if @ == window
    initialize_resource.call(@)
    advisable.call(@)
    $.extend(@, mixin, data)


# @association = ()