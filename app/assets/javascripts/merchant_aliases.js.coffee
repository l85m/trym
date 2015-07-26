format = (merc) ->
  if !merc.id && merc.category
    "<div class='ajax-opt-group'><strong><i class='fa fa-tag'></i> " + merc.category + "</strong></div>"
  else if !merc.category
    merc.text
  else
    "<div class='row'><div class='col-xs-10'>" + merc.text + "</div>" + "<div class='col-xs-2 text-right'>" + merc.score + "</div></div>"

initMerchantAliasSelect2 = (target) ->
  if target.size() > 0
    url = target.data('url')

    target.select2
      minimumInputLength: 0
      formatResult: format
      formatSelection: format
      placeholder: "select merchant"
      allowClear: true
      initSelection: (element, callback) ->
        data = 
          id: element.val()
          text: element.val()
        callback data
      ajax:
        url: url
        dataType: 'json'
        quietMillis: 1
        data: (term, page) ->
          if term == ""
            term = $(this).data("search")
          { q: term, allow_new: false }
        results: (data, page) ->
          { results: data }
        cache: true
      width: '100%'

  return

$ ->
  $(".alias-select2").each (index) ->
    el = $(this)
    initMerchantAliasSelect2 el

    el.on 'select2-selecting', (e) ->
      $.ajax
        type: "PUT"
        url: $(e.target).data("update-url")
        data:
          merchant_alias: 
            merchant_id: e.val
      .fail ->
        el = $(e.target)
        el.select2("val","").blur()
        el.parent().find(".select2-chosen").css("color","red").animate {
          color: "#999"
        }, 2500
        return
      return

    el.on 'select2-removed', (e) ->
      $.ajax
        type: "PUT"
        url: $(e.target).data("update-url")
        data:
          merchant_alias: 
            merchant_id: ""
      return
    return