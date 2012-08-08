@photo = model.call
  resource: 'photo',
  route: 'photos',
  record:
    file: (file) ->
      @file.value = file if file
      @file.value

