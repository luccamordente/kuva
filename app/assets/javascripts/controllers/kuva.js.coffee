#= require jquery
#= require jquery_ujs
#= require modernizr
#= require jqote2
#= require lodash
#= require json2
#= require library/framework/record/adapters/rivets
#= require library/framework/record/associations

kuva = ->

# Framework wide configuration
model.rivets()
model.associable()
$.jqotetag('*')


kuva.service =
  url: "#{document.location.protocol}//#{document.location.host}"


kuva.fn =
  sorts:
    numerical:
      asc:  (a,b) -> a - b
      desc: (a,b) -> b - a


# Application wide initialization
initialize = ->



$(initialize)

@kuva = kuva
