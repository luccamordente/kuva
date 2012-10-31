#= require library/framework/flash

bus = ->
flash = null


controller =

  queue: []

  enqueue: (params...) ->
    console.log "enqueueing", params[0]
    controller.queue.push params

  pause: ->
    console.log "bus paused"
    bus.trigger = bus.publish = controller.enqueue

  resume: ->
    console.log "bus resumed"
    bus.trigger = bus.publish = publisher.publish
    publisher.publish.apply bus, event for event in controller.queue
    controller.queue = []
    true



# Private module components
listener =
  listen: (type, listener) ->
    @listeners[type] ||= []
    @listeners[type].unshift listener
    @
  mute: (type, listener) ->
    throw "bus.off Listener for event of type #{type}, does not exist" if !@listeners[type]

    if listener
      channel = @listener[type]
      index = channel.indexOf(listener)

      if index != -1
        channel.splice index, 1
      else
        console.warn 'Listener', listener,' already removed or not found'

    else
      @listeners[type] = []
    @

# Private module components
publisher =
  key: (event) ->
    return event.key.toString().substring(0, 8) if event.key
    return @key.increment++
  publish: (event, acknowledge) ->
    event = type: event unless event.type
    event.key = publisher.key(event)

    # if event.complete
    #   listener.listen ("complete.#{event.key}", response) ->
    #     event.complete.call(event.target || event.context || event, event);

    console.log('publishing[' + event.key + ']', event.type, event) if (event.type !=  'thumbnailer.progress');

    switch event.destination
      when 'flash'
        try
          flash.publish(event)
        catch e
          console.error(e.message, e)
          return false

      when 'javascript'
      else
        listeners = this.listeners[event.type] || []
        i = listeners.length
        try
          while(i--)
            listeners[i].call(event.target || event.context || event, event)
        catch e
          console.error "#{e.message} #{e} on listener #{listeners[i]}\n #{e.stack}"
          throw "#{e.message} #{e} on listener #{listeners[i]}\n #{e.stack}"
          return false

    event.key

  initialized: ->
    bus.publish $.extend library.flash.session(),
      controller: 'application'
      action: 'initialize_session'
      destination: 'flash'
      type: 'request'

# Private namespace variables
publisher.key.increment = 0;

# Private module variables
errored = (event = {type: 'unknown'}) ->
  switch event.type
    # Flash is going crazy, kill it fast
    # TODO Display error message for this
    when 'error.uncaughted.maxed'
      $(flash).remove()


# Set public methods
bus.key = publisher.key
bus.trigger = bus.publish = publisher.publish
bus.on = bus.listen = listener.listen
bus.off = bus.mute = listener.mute
bus.listeners = {}
bus.pause  = controller.pause
bus.resume = controller.resume

# Application wild initialization
initialize = ->
  flash ||= window.flash[1] if window.flash?
  flash ||= $('object[name="flash"]')[1]

  # TODO pretty error message for this
  console.error('bus: flash not found.') unless flash?

  bus.listen 'error.uncaughted.maxed', errored
  bus.listen 'application.initialized', publisher.initialized

$ initialize

this.bus = bus;