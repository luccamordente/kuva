#= require library/framework/record/adapters/rivets

kuva = ->

# Framework wide configuration
model.rivets()

kuva.service =
  url: "#{document.location.protocol}//#{document.location.host}"

# Application wild initialization
initialize = ->
  $.jqotetag('*')


$(initialize)

@kuva = kuva
