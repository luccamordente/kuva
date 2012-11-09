#= require library/framework/advisable

# TODO support other type of associations
@model = do -> # mixin
  modelable =
    after_mix: []
    record:
      after_save      : []
      after_initialize: []
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

    $.extend instance, $.extend true, @, modelable

    callback.call instance, instance for callback in modelable.after_mix

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

  recordable = {}

  that = (data) ->
    throw "Mixin called incorrectly, call mixin with call method: record.call(object, data)" if @ == window
    advisable.call @
    $.extend @, recordable, data


  that.mix = (blender) ->
    blender recordable

  that
