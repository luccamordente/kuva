#= require kuva
#= require reader
#= require gadget
#= require shelf

that = (options) ->
reader = lib.reader()
gadgets = {}
shelf = null

droppable =
  dragover: (event) -> false 
  droped: (event) ->
    files = event.originalEvent.dataTransfer.files
    droppable.overlay.hide();
             
    if files? && files.length
      reader.read(files)
    else          
      alert('error ao receber arquivos')

    false
  readed: (event) ->

    kuva.publish(
      controller: 'photos'
      action: 'uploaded'
      destination: 'flash'
      type: 'request'
      file:
        name: @file.name
        size: @file.size
        type: @file.type
        data: event.target.result
    )

    reader.next();
  errored: (event) ->
    console.error(event.target.error)
  overlay:                          
    show: ->
      @element.fadeIn()
    hide: ->                            
      @element.fadeOut()
  bind: ->
    $(window).bind('dragenter', (event) ->
       console.log('entered');
       droppable.overlay.show()
     ).bind('drop', @droped)
    
     @overlay.element.bind('dragleave', (event) ->
        console.log('leaved');
        droppable.overlay.hide()
     ).bind('dragover', @dragover).bind('drop', @droped)

# Setup Resize listeners 
# TODO Better listeners interface
kuva.listen('file.selected', (event) ->
    instance = gadget()
    instance.show()
    gadgets[event.key] = instance).
  listen('reader.loadstart', (event) ->
    gadgets[event.key].dispatch('loadstart', event)
  ).
  listen('reader.progress', (event) ->
    gadgets[event.key].dispatch('progress', event)
  ).
  listen('reader.loadend', (event) ->
    gadgets[event.key].dispatch('loadend', event)
  ).
  listen('reader.abort', (event) ->
    gadgets[event.key].dispatch('abort', event)
  ).
  listen('thumbnailer.progress', (event) ->
    gadgets[event.key].dispatch('thumbnailing', event)
  ).
  listen('thumbnailer.encoding', (event) ->
    gadgets[event.key].dispatch('encoding', event)
  ).                             
  listen('thumbnailer.thumbnailed', (event) ->
    gadgets[event.key].dispatch('thumbnailed', event)
)
                                    
# Setup commands
abort = ->
  reader.abort();

# Module methods
initialize = -> 
  $('#abort').bind('click', abort)
  $.jqotetag('*')
  # uploader('#files', {thumbnailer: reader})

  shelf = kuva.shelf('#files', 'object:last')

  # Setup drag and drop
  droppable.overlay.element = $('#overlay')
  reader.read.as('dataURL');
  reader.onloadend = droppable.readed
  reader.onerror = droppable.errored
  droppable.bind()
  #  reader.read.as('dataURL')
                               
$(initialize);
kuva.photos = that;