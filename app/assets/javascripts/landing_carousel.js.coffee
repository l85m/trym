$ ->
  if $("#static-pages-landing").length > 0 || $("#invitations-edit").length > 0 || $("html#invitations-update").length > 0
    $(window).scroll ->
      ### Check the location of each desired element ###
      $('.trym-fade-in').each (i) ->
        top_of_object = $(this).offset().top
        bottom_of_window = $(window).scrollTop() + $(window).height()

        ### If the object is completely visible in the window, fade it in ###

        if bottom_of_window > top_of_object
          $(this).animate { 'opacity': '1' }, 500
        return
      return