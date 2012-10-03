#= require library/framework/advisable

# private methods
rest =
  put : -> rest.request.call @, 'put' , "#{@route}/#{@_id}"
  post: -> rest.request.call @, 'post', @route
  request: (method, url) ->
    data = {}
    data[@resource] = @json()

    $.ajax
      url    : url
      data   : data
      type   : method
      error  : @failed
      success: @saved
      context: @

resource =
  pluralize: (word) ->
    return word + 's'
  parent_id:
    get: -> @[@parent_resource]._id
    set: -> console.error 'Warning changing associations throught parent_id not allowed for security and style guide purposes' # TODO
  initialize: ->
    # TODO route parsing
    @route = "/" + @route if @route and @route.indexOf('/') != 0

    # Set parent attribute and default nested route
    if @parent_resource
      Object.defineProperty @, "#{@parent_resource}_id", resource.parent_id

      # TODO Support route parsing, and change route to /parents/:id/childrens
      if not @route and @["#{@parent_resource}_id"]
        @route = '/' + resource.pluralize(@parent_resource) + '/' + @["#{@parent_resource}_id"] + '/' + resource.pluralize(@resource)

    unless @route
      @route = '/' + resource.pluralize @resource

# TODO support other type of associations
@model = do -> # mixin
  modelable =
    after_initialize: []
    record:
      after_save      : []
      after_initialize: []
    create: (mixed) ->
      # if mixed == array
      #  bulk create multiple itens

  initialize_record = (data = {resource: @resource, parent_resource: @parent_resource}) ->
    data.resource          ||= @resource
    data.parent_resource   ||= @parent_resource
    data.route             ||= @route
    data.nested_attributes   = @nested_attributes || []

    instance = record.call $.extend data, @record # TODO remove @record from outside scop

    # Remove used callbacks
    callback.call instance, instance for callback in instance.after_initialize
    delete instance.after_initialize

    instance


  mixer = (options) ->
    mixer.stale = true unless mixer.stale # Prevent model changes

    instance = $.proxy initialize_record, @
    resource.initialize.call @

    $.extend instance, $.extend true, @, modelable

    callback.call instance, instance for callback in modelable.after_initialize

    # Store model for later use
    mixer[@resource] = instance

  mixer.mix = (blender) ->
    throw "Trying to change model mixin with #{object} but model already used.\nCheck your configuration order" if @stale

    blender modelable

  # window.model
  mixer

@record = do -> # mixin
  mixin =
    save: ->
      # TODO Execute before save callbacks
      rest[if @_id then 'put' else 'post'].call @
    saved: ->
      # parsear resposta do servidor e popular dados no modelo atual
      # tinha pensado em botar as propriedades no modelo mermo, sem criar um "data"
      # dispatchar evento de registro salvo, usando o nome do resource

      callback.call @, @ for callback in model[@resource].record.after_save
    json: ->
      json = {}

      for name, value of @ when $.type(value) isnt 'function'
        continue unless value?  # Bypass null, and undefined values

        if $.type(value) == 'object'
          json["#{name}_attributes"] = value.json() for attribute in @nested_attributes when attribute == name
        else
          json[name] = value

      # TODO Store reserved words in a array
      # Remove model reserved words
      delete json.resource
      delete json.route
      delete json.parent_resource
      delete json.nested_attributes
      delete json.after_save
      delete json.element

      json

  (data) ->
    throw "Mixin called incorrectly, call mixin with call method: record.call(object, data)" if @ == window
    resource.initialize.call @
    advisable.call @
    $.extend @, mixin, data


# Expose usefull resource functions
@model.pluralize = resource.pluralize