attachValidators = () ->
  if $("#addressValidator").size() > 0
    amountField = $('input[id$="charge_attributes_amount"')
    socialField = $('input[id$="last_4_digits_of_social_security_number"]')
    phoneField = $('input[id*="phone_number"]')
    
    if $('input[id*="address"]').size() > 0
      $('input[id*="address"]').parents('form').find("input[type='submit']").click (e) ->
        valid = true
        if $("#street").val() == "" || $("#street").val() == null
          $("#street").parent().addClass("has-error")
          valid = false

        if $("#zip").val() == "" || $("#zip").val() == null
          $("#zip").parent().addClass("has-error")
          valid = false

        if valid
          $('input[id*="address"]').val( $("#street").val() + " " + $("#zip").val() )
        else
          $("#error-row").removeClass("hidden")
          if $("#address-error-msg").length == 0
            $("#error-row").find(".help-block").append("<li id='address-error-msg'>Please complete both street address and zipcode fields</li>")
          e.preventDefault
        return valid

      liveaddress = jQuery.LiveAddress(
        key: $("#addressValidator").data("key")
        autoVerify: true
        autocomplete: true
        submitVerify: true
        addresses: [{
          street: "#street"
          zipcode: "#zip"
        }]
      )

      return

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
