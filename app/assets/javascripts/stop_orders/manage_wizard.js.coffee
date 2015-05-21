attachValidators = () ->
  if $("#addressValidator").size() > 0
    amountField = $('input[id$="charge_attributes_amount"')
    socialField = $('input[id$="last_4_digits_of_social_security_number"]')
    phoneField = $('input[id*="phone_number"]')
    
    if $('input[id*="address"]').size() > 0
      jQuery.LiveAddress({key: $("#addressValidator").data("key"), autoVerify: true})
    
    if socialField.size() > 0
      socialField.formatter({'pattern': '{{9999}}'});
    
    if phoneField.size() > 0
      phoneField.formatter({'pattern': '({{999}}) {{999}}-{{9999}}'});
    
    if amountField.size() > 0
      numericOnly(amountField)

$ ->
  #handle the contact button switch on account_details page
  $('.contactButtonSwitch').click (e) ->
    e.preventDefault()
    
    #update formatting
    $("#contact-options-button-dropdown > li > a.active").removeClass "active"
    $(this).addClass "active" 

    #change button text
    $("#contact-options-button > span.button-text").text $(this).data("where")

    #update request
    $("#stop_order_contact_preference").val $(this).data("medium") 
    return

  attachValidators()
