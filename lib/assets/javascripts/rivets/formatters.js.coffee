$.extend rivets.formatters,
  money: (value) ->
    throw 'Non numerical value passed to money formatter' if not value and value isnt 0
    parseFloat(value).toFixed(2).toString().replace('.', ',');