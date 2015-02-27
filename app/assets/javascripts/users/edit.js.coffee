on_load = ->
  load
    controllers:
      users: ["edit"]
  , (controller, action) ->
    $("#save-languages").click ->
      $('#languageModal').modal('hide')
    initialize_selects = ->
      $(".gender-select").select2({minimumResultsForSearch: -1})
      $(".language-select").select2({minimumResultsForSearch: -1})
      $(".profession-select").select2({minimumResultsForSearch: -1})
      $('.multi-lang-select').select2({minimumResultsForSearch: -1})
    initialize_selects()
  return
$(document).ready on_load
