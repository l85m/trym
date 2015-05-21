@intitializeFieldHelpers = () ->
  $('#charge_trym_category_id').select2({minimumResultsForSearch: Infinity, allowClear: true});

  $("input[id*='billing_day']").datepicker
    dateFormat: 'yy-mm-dd'

  $("*[id*='renewal_period_in_weeks']").select2
    minimumResultsForSearch: Infinity
    data:[
      {id: 1, text: "Weekly - every week"},
      {id: 2, text: "Bi-Weekly - every other week"},
      {id: 4, text: "Monthly - once every month"},
      {id: 8, text: "Bi-Monthly - every other month"},
      {id: 12, text: "Quarterly - once every three months"},
      {id: 16, text: "4-Monthly - once every four months"},
      {id: 26, text: "Bi-Annually - twice a year"},
      {id: 52, text: "Annually - once a year"}
    ]

  amountField = $('#charge_amount')
  if amountField.size() > 0
    numericOnly(amountField)


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

$ ->
  intitializeFieldHelpers()
  activateChargeRow('')
  $("#modal-container").on 'shown.bs.modal', ->
    initMerchantSelect2( $('.modal-dialog').find('#charge_merchant_id') )
    intitializeFieldHelpers()
    $('#charge_merchant_name').focus()
    return