#= require jquery
#= require jquery_ujs
#= require jquery.inview
#= require modernizr
#= require jqote2
#= require lodash
#= require json2
#= require library/framework/record/adapters/rivets
#= require library/framework/record/associations
#= require library/framework/record/resource
#= require library/framework/record/restful
#= require library/framework/record/maid

kuva = ->

# Framework wide configuration
model.rivets()
model.resourceable()
model.restfulable()
model.associable()
# model.maid()

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
