@photo = model.call
  resource: 'photo'
  nested_attributes: ['specification']
  has_one: 'image' # TODO change to belongs_to and make it work
  # washing: true

  record:
    implode: ->
      @dead  = true
      @count = 0