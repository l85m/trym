#= require active_admin/base
#= require json_view

jsonify = () ->
	$('.pretty-json').each (index) ->
		$( this ).JSONView($( this ).data("json"),{ collapsed: true })
		$( this ).parent().find('.pretty-json').JSONView('expand', 1)

		$expandButton = $("<button class='json-expand'>expand</button>")
		$collapseButton = $("<button class='json-collapse'>collpase</button>")

		$( this ).parent().prepend($collapseButton)
		$( this ).parent().prepend($expandButton)

		$expandButton.click (e) -> 
			$( this ).parent().find('.pretty-json').JSONView('expand')
			return
		
		$collapseButton.click (e) ->
			$( this ).parent().find('.pretty-json').JSONView('collapse')
			return
		return
$ -> 
	jsonify()
	return