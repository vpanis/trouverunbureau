on_load = ->
  $(".calendar.input-group input").inputmask("99-99-9999");
  load
    controllers:
      space_booking_inquiry: ["inquiry"]
  , (controller, action) ->
    disable_keyboard_number = ->
      $('[name="booking[quantity]"]').keydown (e) ->
        e = e || window.event
        e.preventDefault()
    $('#languages_spoken_select').change ->
      $('#user_languages_spoken').val($(this).val())
      return

    disable_keyboard_number()

$(document).ready on_load
