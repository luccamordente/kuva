#= require watch
#= require library/framework/shims/defineProperty


@observable = (($) ->

  mixin =

    subscribe: (property_or_watcher, watcher) -> watch @, property_or_watcher, watcher

    unsubscribe: (property_or_watcher, watcher) -> unwatch @, property_or_watcher, watcher

    publish: (property, new_value, old_value) ->
      if arguments.length
        callWatchers @, property, new_value, old_value if @watchers?
      else
        callWatchers @, keypath, @[keypath], @[keypath] for keypath of @watchers


  -> $.extend @, mixin

)(jQuery)






