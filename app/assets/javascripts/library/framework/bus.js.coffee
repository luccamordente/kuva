#= require library/framework/flash
bus = ->
flash = null

listener =
  listen: (type, listener) ->
    @listeners[type] = [] if (!this.listeners[type])
    @listeners[type].push(listener)
    @

publisher =
  key: (event) ->
    return event.key.substring(0, 5) if event.key
    return @key.increment++
  publish: (event) ->
    event.key = publisher.key(event)

    # if event.complete
    #   listener.listen ("complete.#{event.key}", response) ->
    #     event.complete.call(event.target || event.context || event, event);

    console.log('publishing[' + event.key + ']', event.type, event) if (event.type !=  'thumbnailer.progress');

    switch event.destination
      when 'flash'
        try
          flash.publish(event);
        catch e
          console.error(e.message, e)

      when 'javascript'
      else
        listeners = this.listeners[event.type] || []
        i = listeners.length
        try
          while(i--)
            listeners[i].call(event.target || event.context || event, event);
        catch e
          console.error(e.message, e, 'on listener', listeners[i]);

        true

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
bus.publish = publisher.publish
bus.listen = listener.listen
bus.listeners = {}

# Application wild initialization
initialize = ->
  flash ||= window.flash[1] if window.flash?
  flash ||= $('object[name="flash"]')[1]

  # TODO pretty error message for this
  console.error('bus: flash not found.') unless flash?

  bus.listen('error.uncaughted.maxed', errored)
  bus.listen('application.initialized', publisher.initialized)

$(initialize)

this.bus = bus;