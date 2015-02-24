on_load = ->
  load
    controllers:
      users: ["show"]
  , (controller, action) ->
    $(".client-reviews-pagination").hide()
  return
$(document).ready on_load
