kuva = ->

kuva.service =
  url: "#{document.location.protocol}//#{document.location.host}"

  # Application wild initialization
initialize = ->
  $.jqotetag('*')

$(initialize)

this.kuva = kuva
