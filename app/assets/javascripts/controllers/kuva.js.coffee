#= require jquery
#= require jquery_ujs
#= require modernizr
#= require jqote2
#= require library/framework/record/adapters/rivets
#= require library/framework/record/associations

kuva = ->

# Framework wide configuration
model.rivets()
model.associable()

kuva.service =
  url: "#{document.location.protocol}//#{document.location.host}"

# Application wild initialization
initialize = ->
  $.jqotetag('*')


$(initialize)

@kuva = kuva
