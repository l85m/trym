@attachCloseActionToButtons = ->
  $('button.close').click (e) ->
    button = $(e.currentTarget)
    console.log button.parents().find(button.data('target'))
    button.parents().find(button.data('target')).remove()
    return

$(document).on 'page:change', ->
  $('[data-toggle="tooltip"]').tooltip()
  attachCloseActionToButtons