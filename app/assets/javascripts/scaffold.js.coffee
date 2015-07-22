@attachCloseActionToButtons = ->
  $('button.close').click (e) ->
    button = $(e.currentTarget)
    button.parents().find(button.data('target')).remove()
    return

fitToPage = ->
  $('.scrollable').each (i, el) ->
    scrollable = $(this)
    
    if scrollable.length > 0
      if $(window).width() >= 767
        h = $(window).height()
        scrollable.height h - 50 + 'px'
      else
        scrollable.height 'auto'

    if scrollable.hasClass("scroll-pane")
      if scrollable.data("jsp") == undefined
        scrollable.bind 'jsp-initialised', (event, isScrollable) ->
          if isScrollable
            scrollable.css({"border-right":"none"})
          return
        
        scrollable.bind 'jsp-scroll-x', (event, scrollPositionX, isAtLeft, isAtRight) ->
          #prevent horizontal scrolling
          scrollable.find(".jspPane").css("left":"0px")

        if scrollable[0].scrollHeight > ($(window).height() - 50)
          scrollable.jScrollPane()
          scrollable.find(".jspPane").width(scrollable.width()+"px")
      
      else
        if scrollable[0].scrollHeight > ($(window).height() - 50)
          scrollable.width(scrollable.parent().width()+"px")
        else
          scrollable.data("jsp").destroy()
          scrollable.width("auto")
    
    return
  return

navbarCollapseFormatting = ->
  $('#navbar-collapse-menu').on 'show.bs.collapse', ->
    $(".navbar-header").css({"background-color":"#F0F1F4"})
  $('#navbar-collapse-menu').on 'hidden.bs.collapse', ->
    $(".navbar-header").css({"background-color":"transparent"})

@introRunner = ->
	if( $("#charge-side-list").is(":visible") && $("#whoami").data("intro") )
		bootstro.start '',
  	  url: './intro.json'
  	  stopOnBackdropClick: false
  	  onExit: (params) ->
  	    $.get('/account_details/turn_off_intro')
  	    return

@error_button_flash = (button) ->
  #flash button red
  button.css 'background-color', 'red'
  button.css 'border-color', 'red'
  button.css 'color', '#fff'
  button.css 'outline', 'none'
  button.animate { backgroundColor: '##81caa6' },
    queue: false
    duration: 1000
  button.animate { borderColor: '##81caa6' },
    queue: false
    duration: 1000
  button.click ->
    $('#error-text').remove()
    $('.has-error').removeClass 'has-error'
    return
  return

@numericOnly = (input) ->
  pastValue = undefined
  pastSelectionStart = undefined
  pastSelectionEnd = undefined
  input.on('keydown', ->
    pastValue = @value
    pastSelectionStart = @selectionStart
    pastSelectionEnd = @selectionEnd
    return
  ).on 'input propertychange', ->
    regex = /^[0-9]+\.?[0-9]*$/
    if @value.length > 0 and !regex.test(@value)
      @value = pastValue
      @selectionStart = pastSelectionStart
      @selectionEnd = pastSelectionEnd
    return
  return

@makeSwitches = () ->
  if $(".bootstrap-switch").length > 0
    $(".bootstrap-switch").each (i, el) ->
      $(this).bootstrapSwitch()
      if $(this).data("url") != undefined
        $(this).on 'switchChange.bootstrapSwitch', (event, state) ->
          $.ajax
            url: $(this).data('url').replace('placeholder', state.toString())
            type: 'PUT'
          return

$ ->
  $('[data-toggle="tooltip"]').tooltip()
  attachCloseActionToButtons()
  navbarCollapseFormatting()
  fitToPage()
  makeSwitches()

  $(window).resize ->
    fitToPage()
    return