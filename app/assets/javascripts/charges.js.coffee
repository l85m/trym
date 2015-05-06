@activateChargeRow = (cat_id) ->
  $('[name="track-switch"]').off("change").change ->
    state = $(this).is(':checked')
    if state
      charge_params = charge:
        recurring: state
        trym_category_id: cat_id
    else
      charge_params = recurring: state
      if $(this).data('from-link')
        charge_params = $.extend(charge_params, trym_category_id: '')
      charge_params = charge: charge_params
    $.ajax
      type: 'PUT'
      url: '/charges/' + $(this).data('charge-id')
      data: charge_params
      dataType: 'script'
    return
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover
    html: true
    trigger: 'focus'
    title: '<i class="fa fa-calendar"></i> Charge History'
  return

$(document).on 'ready page:load', ->
  activateChargeRow('')