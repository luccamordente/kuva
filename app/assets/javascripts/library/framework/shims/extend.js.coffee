# Extend with defined getters and setters
extend = ->
  target = arguments[0] || {}
  i = 1
  length = arguments.length
  deep = false

  # Handle a deep copy situation
  if ( typeof target == "boolean" )
    deep = target
    target = arguments[1] || {}
    # skip the boolean and the target
    i = 2


  # Handle case when target is a string or something (possible in deep copy)
  if ( typeof target != "object" && !jQuery.isFunction(target) )
    target = {}

  # TODO otimizar extend
  for index in [i...length]

    # Only deal with non-null/undefined values
    if (options = arguments[ i ])?
      # Extend the base object
      for name of options
        src = target[ name ]
        copy = options[ name ]

        # Prevent never-ending loop
        continue if target == copy

        # Copy getters and setters
        getter = options.__lookupGetter__ name
        setter = options.__lookupSetter__ name

        if ( getter || setter )
          target.__defineGetter__ name, getter if getter

          if setter
            target.__defineSetter__ name, setter
            continue

        #Recurse if we're merging plain objects or arrays
        if ( deep && copy && ( jQuery.isPlainObject(copy) || (copyIsArray = jQuery.isArray(copy)) ) )
          if ( copyIsArray )
            copyIsArray = false;
            clone = src && if jQuery.isArray(src) then src else []
          else
            clone = src && if jQuery.isPlainObject(src) then src else {}


          # Never move original objects, clone them
          target[ name ] = jQuery.extend( deep, clone, copy )

        # Don't bring in undefined values
        else if ( copy != undefined )
          target[ name ] = copy




    # Return the modified object
    return target

# TODO ! $.extend = extend if $ and $.extend
