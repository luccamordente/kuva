#= require watch
#= require library/framework/shims/defineProperty


@observable = (($) ->

  mixin =

    subscribe: (property_or_watcher, watcher) ->
      if watcher?
        watch @, property_or_watcher, watcher
      else
        watch @, property_or_watcher

    unsubscribe: (property_or_watcher, watcher) ->
      if !arguments.length
        arguments.callee.call @, prop for prop of @

      if watcher?
        unwatch @, property_or_watcher, watcher
      else if property_or_watcher?
        if $.type(property_or_watcher) is 'function'
          unwatch @, property_or_watcher
        else
          if $.type(@[property_or_watcher]) == 'array'
            copy = Array.prototype.splice.call @[property_or_watcher]
            delete @[property_or_watcher]
            @[property_or_watcher] = copy
            #for method in ['pop', 'push', 'reverse', 'shift', 'sort', 'slice', 'unshift']
            #  delete @[prop][method]
            #  @[prop][method] = Array.prototype[method]
            delete @watchers[property_or_watcher] if @watchers



    publish: (property, new_value, old_value) ->
      try
        if arguments.length
          callWatchers @, property, new_value, old_value if @watchers?
        else
          callWatchers @, keypath, @[keypath], @[keypath] for keypath of @watchers
      catch e
        throw e if e.type isnt 'circular_structure'


  -> $.extend @, mixin

)(jQuery)


observable.unobserve = (object) ->
  observable.call({}).unsubscribe.call object

