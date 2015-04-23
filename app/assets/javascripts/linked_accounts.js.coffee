# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@waitForPlaidToAddUser = (linked_account_path) ->
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
      url: linked_account_path
      dataType: 'json'
      success: (json) ->
        if json.last_api_response == null
        else if json.last_api_response.response_code == '200'
          clearInterval i
          submit_button.html '<i class=\'fa fa-check\'></i>Linked</button>'
          $('.modal-content').animate { height: '195px' }, 1100
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

