@advisable = (($) -> # mixin
  advice =
		around: (base, wrapped) ->
      ->
        args = $.makeArray(arguments)
        wrapped.apply(@, [$.proxy(base, @)].concat(args))
		before: (base, before) ->
			@around(base, ->
				args = $.makeArray(arguments)
				orig = args.shift()

				before.apply(@, args)
				orig.apply(@, args)
			)

		after: (base, after) ->
			@around(base, ->
				args = $.makeArray(arguments)
				orig = args.shift()
				res = orig.apply(@, args)

				after.apply(@, args)
				res
			)

  mixin =
    before: (method, advicer) ->
      if (typeof @[method] == 'function')
        @[method] = advice.before(@[method], advicer);
      else
        @[method] = advicer
    after: (method, advicer) ->
      if (typeof @[method] == 'function')
        @[method] = advice.after(@[method], advicer);
      else
        @[method] = advicer
    around: (method, advicer) ->
      if (typeof @[method] == 'function')
        @[method] = advice.around(@[method], advicer);
      else
        @[method] = advicer

  ->
  	$.extend(@, mixin)
)(jQuery)
