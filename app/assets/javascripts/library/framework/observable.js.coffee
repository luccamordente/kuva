#= require library/framework/shims/defineProperty

@observable = (($) ->
  mixin =
    subscribe: (keypath, callback) ->
      @["_#{keypath}"] = @[keypath] unless @["_#{keypath}"]

      current_setter = @__lookupSetter__ keypath
      current_getter = @__lookupGetter__ keypath

      if current_setter
        setter = (value) ->
          current_setter.call @, value
          callback.call @, value
      else
        setter = (value) ->
          @["_#{keypath}"] = value
          callback.call @, value

      # TODO onpropertychange
      Object.defineProperty @, keypath,
        get: current_getter || -> @["_#{keypath}"]
        set: setter

    unsubscribe: (object, keypath, callback) ->

      # TODO look up getter
      ->
        console.log(object, keypath, callback)

    publish: (object, keypath, value) ->
      object[keypath] = value

  -> $.extend @, mixin

)(jQuery)