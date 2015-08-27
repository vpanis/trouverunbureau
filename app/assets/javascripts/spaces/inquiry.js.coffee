on_load = ->
  load
    controllers:
      space_booking_inquiry: ["inquiry"]
  , (controller, action) ->

    disable_keyboard_number = ->
    $($('[name="booking[quantity]"]')).keydown (e) ->
      e = e || window.event
      e.preventDefault()
      return false

    disable_keyboard_number()

$(document).ready on_load
