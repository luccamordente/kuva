((library) ->
  @flash = ->

  @flash.session = (data) ->
    return @data if @data
    @data = data

  library.flash = @flash
).call @framework ||= {}, @library ||= {}
