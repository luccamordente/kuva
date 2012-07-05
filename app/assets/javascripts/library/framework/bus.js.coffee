bus = ->
flash = null

listener =
  listen: (type, listener) ->
    this.listeners[type] = [] if (!this.listeners[type])
    this.listeners[type].push(listener)
    this

publisher =
  publish: (event) ->
    event.key = event.key.substring(0, 5) if event.key

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
          console.error(e.message, e);

        true

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

$(initialize)

this.bus = bus;