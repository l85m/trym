mercFormatWide = (merc) ->
  if !merc.id 
    "<div class='ajax-opt-group'><strong><i class='fa fa-tag'></i> " + merc.category + "</strong></div>"
  else if !merc.category
    "<div class='row'><div class='col-sm-12' style='color:gray'>" + merc.text + "</div></div>"
  else
    "<div class='row'><div class='col-sm-6'>" + merc.text + "</div><div class='col-sm-6 text-right'><small>" + merc.category + "</div></div>"

mercFormatNarrow = (merc) ->
  if !merc.id 
    "<div class='ajax-opt-group'><strong><i class='fa fa-tag'></i> " + merc.category + "</strong></div>"
  else if !merc.category
    "<div class='row'><div class='col-sm-12' style='color:gray'>" + merc.text + "</div></div>"
  else
    "<div class='row'><div class='col-sm-12'>" + merc.text + "</div></div>"


@initMerchantSelect2 = (target) ->
  if target.size() > 0
    url = target.data('url')
    placeholder = target.data('placeholder')

    if target.parent().width() < 300
      format = mercFormatNarrow
    else
      format = mercFormatWide

    if target.data("init")
      initValue = target.data("init")
    else
      initValue = {}

    target.select2
      placeholder: placeholder
      formatResult: format
      initSelection : (element, callback) ->
        callback( initValue )
      minimumInputLength: 0
      ajax:
        url: url
        dataType: 'json'
        quietMillis: 1
        data: (term, page) ->
          { q: term }
        results: (data, page) ->
          { results: data }
        cache: true
      width: '100%'
      dropdownCssClass: 'new-user-select2-dropdown'

    target.on 'change', (e) ->
      $('#disabled-next-button').hide()
      $('#enabled-next-button').css 'display', 'inline'
      return

    target.on "select2-loaded", (e) ->
      $(".ajax-opt-group").parent().parent().removeClass("select2-result select2-result-selectable select2-highlighted").addClass("select2-result-label")
      $("nav").after("<div id='merchant-disclaimer'><p>Trym is not affiliated with any service provider whose name, logo or other trademark may appear on this website.</p></div>")
      $('#merchant-disclaimer').animate({opacity: 1}, 500)
      return

    target.on "select2-close", (e) ->
      $('#merchant-disclaimer').animate {opacity: 0}, 500, ->
        $('#merchant-disclaimer').remove()
        return
      return

$(document).on 'ready page:load', ->
  initMerchantSelect2( $("#charge_merchant_id") )