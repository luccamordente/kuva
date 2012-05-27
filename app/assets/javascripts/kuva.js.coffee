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
      event.key = event.key.substring(0, 5);
      console.log('publishing[' + event.key + ']', event.type, Date.now())
      switch event.destination
        when 'flash'
          console.log('sending to flash');
          flash.publish(event);
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

  # Set public methods
  that.publish = publisher.publish
  that.listen = listener.listen
  that.listeners = {}
  that.service =
    url: document.location.origin

  # Application wild intiialization
  initialize = ->
    flash ||= window.flash[1] if window.flash?
    flash ||= $('object[name="flash"]')[1]
    console.error('kuva: flash not found.') unless flash?

    $.jqotetag('*');
                                            
  $(initialize)
                           
  return that
).call(this)