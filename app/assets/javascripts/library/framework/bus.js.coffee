#= require library/framework/flash

bus = ->

flash = null


timeflow =
  speed: 10
  regulate: (speed) ->
    console.log "changing bus speed to #{speed}"
    this.speed = speed
    bus.trigger = bus.publish = if this.speed == 0 then publisher.publish else controller.enqueue


process = ->
  if controller.queue.length > 0
    controller.next()
    publisher.publish.apply bus, controller.queue.shift()


controller =

  paused: false

  queue: []

  next: -> controller.timeout = setTimeout controller.process, timeflow.speed

  enqueue: ->
    event = arguments[0]
    # skiping thumbnailer.progressed event when queue is too large
    if event.type ==  'thumbnailer.progressed' and controller.queue.length > 20
      console.log controller.queue.length
      return
    console.log "⥤ enqueueing", event.type, event, arguments
    controller.queue.push arguments
    controller.next() if controller.queue.length == 1

  process: process

  pause: ->
    console.log "bus paused"
    controller.process = $.noop
    clearTimeout controller.timeout
    true

  resume: ->
    console.log "bus resumed"
    controller.process = process
    controller.next()
    true



# Private module components
listener =
  listen: (type, listener) ->
    @listeners[type] ||= []
    @listeners[type].unshift listener
    @
  one: (type, listener) ->
    bus.listen type, ->
      listener()
      bus.mute type, arguments.callee
    @
  mute: (type, listener) ->
    throw "bus.off Listener for event of type #{type}, does not exist" if !@listeners[type]

    if listener
      channel = @listeners[type]
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

    console.log('⬇ publishing[' + event.key + ']', event.type, event)# if (event.type !=  'thumbnailer.progress');

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
bus.key     = publisher.key
bus.trigger = bus.publish = controller.enqueue
bus.on      = bus.listen  = listener.listen
bus.off     = bus.mute    = listener.mute
bus.one     = listener.one
bus.pause   = controller.pause
bus.resume  = controller.resume

bus.listeners = {}


Object.defineProperty bus, 'speed',
  get:        -> timeflow.speed
  set: (speed)-> timeflow.regulate(speed)

# Application wild initialization
initialize = ->
  flash ||= window.flash[1] if window.flash?
  flash ||= $('object[name="flash"]')[1]

  # TODO pretty error message for this
  console.error('bus: flash not found.') unless flash?

  bus.listen 'error.uncaughted.maxed', errored
  bus.listen 'application.initialized', publisher.initialized

$ initialize

this.bus = bus