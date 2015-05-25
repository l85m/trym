#= require active_admin/base
#= require json_view

jsonify = () ->
	$('.pretty-json').each (index) ->
		data = $( this ).data("json")
		$( this ).JSONView( data, { collapsed: true } )
		$( this ).parent().find('.pretty-json').JSONView('expand', 1)
		
		if $( this ).data("controls") == true
			$expandButton = $("<button class='json-expand'>expand</button>")
			$collapseButton = $("<button class='json-collapse'>collpase</button>")

			$( this ).parent().parent().find("th").append("<br>")	
			$( this ).parent().parent().find("th").append($expandButton)
			$( this ).parent().parent().find("th").append("<br>")
			$( this ).parent().parent().find("th").append($collapseButton)

			$expandButton.click (e) -> 
				$( this ).parent().parent().find("td").find('.pretty-json').JSONView('expand')
				return
			
			$collapseButton.click (e) ->
				$( this ).parent().parent().find("td").find('.pretty-json').JSONView('collapse')
				return
			return
		return
	return


$ -> 
	jsonify()
	return