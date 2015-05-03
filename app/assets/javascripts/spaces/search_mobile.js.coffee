on_load = ->
  load
    controllers:
      spaces: ["search_mobile"]
  , (controller, action) ->
    $(".workspaces-select").select2()
    return
$(document).ready on_load
