#= require library/framework/shims/defineProperty

@observable = (($) ->
  mixin =
    subscribe: (keypath, callback) ->
      @["_#{keypath}"] = @[keypath] unless @["_#{keypath}"]

      current_setter = @__lookupSetter__ keypath
      current_getter = @__lookupGetter__ keypath

      if current_setter
        setter = (value) ->
          callback.call @, value
          current_setter.call @, value
      else
        setter = (value) ->
          callback.call @, value
          @["_#{keypath}"] = value


      # domo = @[keypath]

      # TODO onpropertychange
      Object.defineProperty @, keypath,
        get: current_getter || -> @["_#{keypath}"]
        set: setter

      # @["_#{keypath}"] = domo

    unsubscribe: (object, keypath, callback) ->

      # TODO look up getter
      ->
        console.log(object, keypath, callback)

    publish: (object, keypath, value) ->
      object[keypath] = value

  -> $.extend @, mixin

)(jQuery)