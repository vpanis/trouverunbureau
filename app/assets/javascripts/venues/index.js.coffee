on_load = ->
  load
    controllers:
      venues: ["index"]
  , (controller, action) ->
    $( ".panel-heading a" ).click ->
      event.stopPropagation()

$(document).ready on_load
