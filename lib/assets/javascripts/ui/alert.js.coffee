#= require 'alertify'

throw 'Alertify not loaded!' unless alertify

delay = 15000

@alerty =
  success: (message, wait) -> alertify.log message, 'success', if wait? then wait else delay
  error  : (message, wait) -> alertify.log message, 'error'  , if wait? then wait else delay
  warn   : (message, wait) -> alertify.log message, 'warn'   , if wait? then wait else delay
  log    : alertify.log
