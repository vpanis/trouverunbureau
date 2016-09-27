on_load = ->
  load
    controllers:
      bookings: ["venue_paid_bookings", "paid_bookings"]
  , (controller, action) ->
    initialize_selects = ->
      $('#venue_id').select2()

    initialize_listeners = ->
      $('#venue_id').change ->
        $('#venue_selector').submit()
      $("button[id^='claim-modal-btn']").click ->
        location.reload()
      return

    initialize_selects()
    initialize_listeners()

  return
$(document).ready on_load
