#= require library/framework/shims/defineProperty

@observable = (($) ->
  mixin =
    subscribe: (keypath, callback) ->
      console.log('subscribing', @, keypath, callback)

      @["_#{keypath}"] = @[keypath] unless @["_#{keypath}"]

      current_setter = @__lookupSetter__ keypath

      if current_setter
        setter = (value) ->
          current_setter value
          callback value
      else
        setter = (value) ->
          @["_#{keypath}"] = value
          callback value

      # TODO onpropertychange
      Object.defineProperty @, keypath,
        get: -> @["_#{keypath}"]
        set: setter

    unsubscribe: (object, keypath, callback) ->
      console.log('unsubscribing', object, keypath, callback)

      # TODO look up getter
      ->
        console.log(object, keypath, callback)

    publish: (object, keypath, value) ->
      console.log 'setting', keypath, value
      object[keypath] = value

  -> $.extend @, mixin

)(jQuery)