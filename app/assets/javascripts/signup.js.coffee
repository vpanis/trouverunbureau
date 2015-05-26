on_load = ->
  load
    controllers:
      registrations: ["new"]
  , (controller, action) ->
    $("#signup-form-submit").click( ->
      $('#unaccepted_terms').addClass('error--hidden')
      if ($('#terms_accepted').is(':checked'))
        $('#new_user').find(':submit').click()
      else
        $('#unaccepted_terms').removeClass('error--hidden')
    )
$(document).ready on_load
