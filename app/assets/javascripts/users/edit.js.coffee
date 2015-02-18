on_load = ->
  load
    controllers:
      users: ["edit"]
  , (controller, action) ->
    $(".gender-select").select2({minimumResultsForSearch: -1})
    $(".profession-select").select2({minimumResultsForSearch: -1})
  return
$(document).ready on_load
