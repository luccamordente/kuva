#= require 'alertify'

throw 'Alertify not loaded!' unless alertify

delay = 15000

@alerty =
  success: (message, wait) -> alertify.log message, 'success', wait || delay
  error  : (message, wait) -> alertify.log message, 'error'  , wait || delay
  warn   : (message, wait) -> alertify.log message, 'warn'   , wait || delay
  log    : alertify.log
