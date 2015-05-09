# jQuery.support.transition
# to verify that CSS3 transition is supported (or any of its browser-specific implementations)
+(($) ->
  # CSS TRANSITION SUPPORT (Shoutout: http://www.modernizr.com/)
  # ============================================================

  transitionEnd = ->
    el = document.createElement('bootstrap')
    transEndEventNames = 
      WebkitTransition: 'webkitTransitionEnd'
      MozTransition: 'transitionend'
      OTransition: 'oTransitionEnd otransitionend'
      transition: 'transitionend'
    for name of transEndEventNames
      if el.style[name] != undefined
        return { end: transEndEventNames[name] }
    false
    # explicit for ie8 (  ._.)

  'use strict'
  # http://blog.alexmaccaw.com/css-transitions

  $.fn.emulateTransitionEnd = (duration) ->
    called = false
    $el = this
    $(this).one 'bsTransitionEnd', ->
      called = true
      return

    callback = ->
      if !called
        $($el).trigger $.support.transition.end
      return

    setTimeout callback, duration
    this

  $ ->
    $.support.transition = transitionEnd()
    if !$.support.transition
      return
    $.event.special.bsTransitionEnd =
      bindType: $.support.transition.end
      delegateType: $.support.transition.end
      handle: (e) ->
        if $(e.target).is(this)
          return e.handleObj.handler.apply(this, arguments)
        return
    return
  return
)(jQuery)