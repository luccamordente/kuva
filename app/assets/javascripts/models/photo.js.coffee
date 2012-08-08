@photo = model.call
  resource: 'photo',
  record:
    file: (file) ->
      @file.value = file if file
      @file.value

