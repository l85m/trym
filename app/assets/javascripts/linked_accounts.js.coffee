# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@waitForPlaidToAddUser = (linkedAccountPath) ->
  if $('#new_linked_account').is(':visible')
    submit_button_text = 'Link Account'
    current_form = 'credentials'
  else
    submit_button_text = 'Continue'
    current_form = 'mfa'
  submit_button = $('#' + current_form + '-submit-button')
  error_container = $('#' + current_form + '-error-container')
  form_container = $('#' + current_form + '-form-container')
  submit_button.html '<i class=\'fa fa-cog fa-spin fa-fw\'></i>Working</button>'
  # this function will run each 1000 ms until stopped with clearInterval()
  i = setInterval((->
    $.ajax
      url: linkedAccountPath
      dataType: 'json'
      success: (json) ->
        if json.last_api_response == null
        else if json.last_api_response.response_code == '200'
          clearInterval i
          $('.modal-content').animate { height: '305px' }, 1100
          form_container.fadeOut 1000, ->
            $('#link-success-container').fadeIn()
            return
        else if json.last_api_response.response_code == '201'
          clearInterval i
          form_container.fadeOut 500, ->
            submit_button.html submit_button_text
            $('label[for=\'linked_account_mfa_response\']').text json.mfa_prompt
            $('#linked_account_mfa_response').val ''
            $('#mfa-form-container').fadeIn()
            return
        else
          clearInterval i
          submit_button.html submit_button_text
          flash_error_button submit_button
          error_container.html '<p class=\'form-errors\'>' + json.error_message + '</p>'
        return
      error: ->
        # on error, stop execution
        submit_button.html submit_button_text
        flash_error_button submit_button
        error_container.html '<p class=\'form-errors\'>Could not communicate with server, please try again</p>'
        clearInterval i
        return
    return
  ), 1000)


#update user for syncing/analyzing account
@updateLinkedAccountStatus = (data) ->
  if data.message.flash != ''
    $.jGrowl data.message.flash,
      header: '<i class=\'fa fa-credit-card\'></i> ' + data.linked_account_name
      sticky: true
  
  if $('#linked-account-index').is(":visible")
    row = $("li[data-linked-account-id=" + data.linked_account_id + "]")
    button = '<a class="btn btn-primary btn-responsive linked-account-button"></a>'

    button = row.find(".linked-account-button").parent().html(button).find("a")
    
    button.html( "<i class='fa fa fa-" + data.message.button_icon + "'></i> " + data.message.button_text )
    button.attr('href',data.message.button_link)
    
    if data.message.button_disabled_state == "false"
      button.removeAttr('disabled')
    else
      button.attr('disabled','disabled')

    button.removeData("toggle").removeData("title")
    button.removeAttr("data-toggle").removeAttr("data-title")
    button.parent().tooltip('destroy')

    if data.message.button_tooltip != ''
      button.parent().tooltip({title:data.message.button_tooltip})

$ ->
  if $('#whoami').length
    # Pusher.log = (message) ->
    #   if window.console and window.console.log
    #     window.console.log message
    #   return

    pusher = new Pusher('98d6e8e3a6d1437792da', { encrypted: true })
    channel = pusher.subscribe('private-user-' + $('#whoami').data("user-id") + '-channel')
    channel.bind 'linked-account-notifications', (data) ->
      updateLinkedAccountStatus(data)
      return