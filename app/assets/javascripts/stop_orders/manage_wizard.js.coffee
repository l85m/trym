# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  #handle the contact button switch on account_details page
  $('.contactButtonSwitch').click (e) ->
    e.preventDefault()
    
    #update formatting
    $("#contact-options-button-dropdown > li > a.active").removeClass "active"
    $(this).addClass "active" 

    #change button text
    $("#contact-options-button > span.button-text").text $(this).data("where")
    $("#contact-verb").text $(this).data("medium")

    #update request
    $("#stop_order_contact_preference").val $(this).data("medium") 

