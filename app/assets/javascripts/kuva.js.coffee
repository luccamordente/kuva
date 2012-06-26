this.kuva = (->
  that = ->
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
  that.publish = publisher.publish
  that.listen = listener.listen
  that.listeners = {}
  that.service =
    url: "#{document.location.protocol}//#{document.location.host}"

  # Application wild initialization
  initialize = ->
    flash ||= window.flash[1] if window.flash?
    flash ||= $('object[name="flash"]')[1]

    # TODO pretty error message for this
    console.error('kuva: flash not found.') unless flash?

    that.listen('error.uncaughted.maxed', errored)

    $.jqotetag('*')

  $(initialize)

  return that
).call(this)