on_load = ->
  fbLogin = $('#invisible').data('fblogin');
  if typeof fbLogin == 'boolean'
    if fbLogin
      $(".fb-login-button").hide();
      $(".section-separator").hide();
  load
    controllers:
      registrations: ["new"]
      omniauth_callbacks: ['facebook']
  , (controller, action) ->
    $("#signup-form-submit").click( ->
      $('#unaccepted_terms').addClass('error--hidden')
      if ($('#terms_accepted').is(':checked'))
        $('#new_user').find(':submit').click()
      else
        $('#unaccepted_terms').removeClass('error--hidden')
    )
$(document).ready on_load
