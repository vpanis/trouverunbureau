on_load = ->
  load
    controllers:
      bookings: ["venue_paid_bookings", "paid_bookings"]
  , (controller, action) ->
    initialize_selects = ->
      $('#venue_ids').select2()

    initialize_listeners = ->
      return

    initialize_selects()
    initialize_listeners()

  return
$(document).ready on_load
