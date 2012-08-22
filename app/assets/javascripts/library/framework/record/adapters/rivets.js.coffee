#= require rivets
#= require library/framework/record
#= require library/framework/observable

model.rivets = ->
  model.mix record: window.observable.call {}

  rivets.configure
    adapter:
      subscribe: (object, keypath, callback) ->
        object.subscribe keypath, callback
      unsubscribe: (object, keypath, callback) ->
        object.unsubscribe keypath, callback
      read: (object, keypath) ->
        object[keypath]
      publish: (object, keypath, value) ->
        # TODO if (value != object[keypath]) object.changed()
        object[keypath] = value