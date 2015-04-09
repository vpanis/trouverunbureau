on_load = ->
  load
    controllers:
      venues: ["index"]
  , (controller, action) ->
    $('.panel-heading').click ->
     $(this).toggleClass 'open'

$(document).ready on_load
