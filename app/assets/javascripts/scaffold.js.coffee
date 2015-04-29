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

$(document).on 'ready page:load', ->
  $('[data-toggle="tooltip"]').tooltip()
  attachCloseActionToButtons()
  introRunner()