@photo = model.call
  resource: 'photo',
  nested_attributes: ['specification']
  has_many: 'image'