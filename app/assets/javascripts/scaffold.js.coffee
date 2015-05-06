@attachCloseActionToButtons = ->
  $('button.close').click (e) ->
    button = $(e.currentTarget)
    console.log button.parents().find(button.data('target'))
    button.parents().find(button.data('target')).remove()
    return

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

$(document).on 'ready page:load', ->
  $('[data-toggle="tooltip"]').tooltip()
  attachCloseActionToButtons()
  introRunner()