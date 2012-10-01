model.associable = ->
  model.mix (modelable) ->
    modelable.after_initialize.unshift associable.model
    modelable.record.after_initialize.unshift associable.record

associable =
  model: (options) ->
    console.error 'resource must be defined in order to associate' unless @resource?

    callbacks =
      has_many:
        autosave: ->
          @save()

    # Store association methods
    has_many =
      add  : (record)    -> @push @build @
      build: (data = {}) ->
        data.parent_resource = @parent_resource

        # TODO Setup a before save callback to generate rout when there is no id
        data.route = "/#{@parent_resource}/#{@_id}/#{data.resource}" if @_id?
        model[@parent_resource] data
      push : Array.prototype.push
      # TODO throught:

    singular =
      create: (data) -> model[@resource].create $.extend {}, @, data
      build : (data) -> model[@resource]        $.extend {}, @, data

    # TODO autosave
    # @record.after_save ->
    #   model[@resource] =

    @create_association_methods = ->
      # Create association methods
      if options.has_many
        options.has_many = [options.has_many] unless $.type(options.has_many) == 'array'

        for resource in options.has_many
          @[model.pluralize resource] = $.extend resource: resource, parent_resource: @resource, has_many

      if options.has_one
        options.has_one = [options.has_one] unless $.type(options.has_one) == 'array'

        for resource in options.has_one
          association_proxy = resource: resource, parent_resource: @resource
          association_proxy[@resource] = @

          @["build_#{resource}" ] = $.proxy singular.build , association_proxy
          @["create_#{resource}"] = $.proxy singular.create, association_proxy

      if options.belongs_to
        options.belongs_to = [options.belongs_to] unless $.type(options.belongs_to) == 'array'

        for resource in options.belongs_to
          association_proxy = resource: resource, parent_resource: @resource

          # TODO override default setter to set resource_id from parent resource FTW!
          association_proxy[@resource] = @

          @["build_#{resource}" ] = $.proxy singular.build , association_proxy
          @["create_#{resource}"] = $.proxy singular.create, association_proxy

  record: (options) ->
    console.error 'resource must be defined in order to associate' unless @resource?
    model[@resource].create_association_methods.call @
