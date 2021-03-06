#= require rivets
#= require library/framework/record
#= require library/framework/observable

model.rivets = ->

  model_extensions =
    record:
      tie: (element) ->
        lasso = {}
        lasso[@resource] = @
        rivets.bind element, lasso

  # TODO add support to subscriptions in arrays
  rivets.configure
    adapter:
      subscribe: (record, attribute_path, callback) ->
        #console.log 'subscribe', record, attribute_path
        record.subscribe attribute_path, callback
      unsubscribe: (record, attribute_path, callback) ->
        #console.log 'unsubscribe', record, attribute_path
        record.unsubscribe attribute_path, callback
      read: (record, attribute_path) ->
        #console.log 'read', record, attribute_path
        record[attribute_path]
      publish: (record, attribute_path, value) ->
        #console.log 'publish', record, attribute_path, value
        # TODO if (value != record[attribute_path]) record.changed()
        record[attribute_path] = value
    preloadData: true

  model.mix (modelable) ->
    modelable.record ||= {}

    window.observable.call modelable.record
    $.extend true, modelable, model_extensions
