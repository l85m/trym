fadeInCancelProgress = ->
  console.log "test"
  $(".bs-wizard").animate({"opacity":1}, 1500)

clickButton = (touch) ->
  touch.addClass('pop').css
    'top': touch.offset().top - 35 + 'px'
    'left': touch.offset().left - 35 + 'px'
  window.setTimeout fadeInCancelProgress, 500

demoClickButton = (btn) ->
  b = $("<span id='demo-touch'></span>")
  t = btn.offset().top + (btn.outerHeight() - 30) / 2
  w = btn.offset().left + (btn.outerWidth() - 30) / 2

  b.css {'top': t + 'px', 'left': w + 'px'}
  
  $('html').prepend b
  window.setTimeout clickButton, 200, b

setCarouselHeight = (carousel) ->
  if carousel.length > 0
    h = ($(window).height() - $(".header-padding").height()) + "px"
    carousel.css({"height":h})
    $(window).resize ->
      h = ($(window).height() - $(".header-padding").height()) + "px"
      carousel.css({"height":h})

$ ->
  if $("#static-pages-landing").length > 0 || $("#invitations-edit").length > 0 || $("html#invitations-update").length > 0
    carousel = $("#home-carousel")
    setCarouselHeight carousel

    carousel.on 'slid.bs.carousel', ->
      carousel.find('.carousel-control').removeClass('hidden')
      if $("#slide-three").is(":visible") && $(".bs-wizard").css("opacity") == "0"
        window.setTimeout demoClickButton, 3500, $($('.charge-buttons .btn')[2])