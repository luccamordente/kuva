@photo = model.call
  resource: 'photo',
  nested_attributes: ['specification']
  # TODO Extract connection layer from the record.js
  # record:
  #   file: (file) ->
  #    @file.value = file if file
  #    @file.value



# photo_model = model.call
#   resource: 'photo',
#   record:
#     file: (file) ->
#       @file.value = file if file
#       @file.value
#
# @photo = (data) ->
#   # TODO improve model method support
#   associations.call photo_model(data)
#
# # TODO Make association a generic method
# associations = ->
#
#   record = @
#   mixin_specification =
#     build: (data = {}) ->
#       data.order = record
#       data.parent_resource = "photo"
#       data.as_nested_attributes = true
#       window.specification data
#
#
#   $.extend(@, specification: mixin_specification)
