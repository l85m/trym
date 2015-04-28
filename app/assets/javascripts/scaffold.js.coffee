@attachCloseActionToButtons = ->
  $('button.close').click (e) ->
    button = $(e.currentTarget)
    console.log button.parents().find(button.data('target'))
    button.parents().find(button.data('target')).remove()
    return

$(document).on 'ready page:load', ->
  $('[data-toggle="tooltip"]').tooltip()
  attachCloseActionToButtons()
  