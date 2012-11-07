model = window.model

model.restfulable = ->
  resource =
    save: () ->
      # TODO Dirty
      self = @
      @delay && clearTimeout @delay
      @delay = setTimeout ->
        promise = rest[if self._id then 'put' else 'post'].call self
        promise.done self.saved
        promise.fail self.failed
        # Bind one time save callbacks
        promise.done argument for argument in arguments when $.type(argument) is 'function'
        promise
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
      # Remove model reserved words
      delete json.resource
      delete json.route
      delete json.parent_resource
      delete json.nested_attributes
      delete json.on_save
      delete json.after_save
      delete json.element

      json


  record.mix (recordable) ->
    $.extend true, recordable, resource

  model.associable && model.associable.mix (singular_association,  plural_association) ->
   plural_association.post = rest.post


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
      context: @