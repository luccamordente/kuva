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
      after_save                : []
      after_initialize          : []
    all: ->
      # TODO transform model in a array like object and store cache in root
      @cache
    # TODO better find support
    create: (params...) ->
      @(attributes).save for attributes in params
    find: (id) ->
      @where id: id, true
    where: (conditions, first = false) ->
      results = []
      conditions.id = [conditions.id] if $.type(conditions.id) != 'array'
      # TODO transform model in a array like object and store cache in root
      for record in @cache when conditions.id.indexOf(record._id) isnt -1
        if first
          return record
        else
          results.push record

      if first then null else results

  initialize_record = (data = {resource: @resource, parent_resource: @parent_resource}) ->
    data.resource          ||= @resource
    data.parent_resource   ||= @parent_resource
    data.route             ||= @route
    data.nested_attributes   = @nested_attributes || []

    instance = record.call $.extend data, @record # TODO remove @record from outside scop

    # Call and remove used callbacks
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
  temporary_callbacks = (record, callbacks) ->
      callbacks = Array.prototype.slice.call(callbacks, 0) unless $.type(callbacks) == 'array'

      callbacks.push ->
        # This code assumes that all bound callbacks in the same slice!
        index = record.after_save.indexOf(callbacks[0])
        record.after_save.splice(index, callbacks.length)

      record.after_save = record.after_save.concat callbacks

  mixin =
    save: () ->
      # Bind one time save callbacks
      temporary_callbacks  @, arguments if arguments.length and $.type(arguments[0]) is 'function'
      self = @

      # TODO Execute before save callbacks
      @delay && clearTimeout @delay
      @delay = setTimeout ->
        rest[if self._id then 'put' else 'post'].call self
      , 20
    saved: (data) ->
      # parsear resposta do servidor e popular dados no modelo atual
      # dispatchar evento de registro salvo, usando o nome do resource
      callback.call @, data for callback in @after_save
    failed: ->
      throw "#{@resource}.save: Failed to save record: #{@}\n"
    json: ->
      json = {}

      for name, value of @ when $.type(value) isnt 'function'
        continue unless value?  # Bypass null, and undefined values

        if $.type(value) == 'object'
          # TODO move nested attributes to model definition
          json["#{name}_attributes"] = value.json() for attribute in @nested_attributes when attribute == name
        else
          json[name] = value

      # TODO Store reserved words in a array
      # TODO User _.omit function
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