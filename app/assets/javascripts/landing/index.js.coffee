on_load = ->
  load
    controllers:
      landing: ["index"]
  , (controller, action) ->
    new google.maps.places.Autocomplete(document.getElementById('search'))
    $(".workspaces-select").select2({minimumResultsForSearch: -1})
    $(".nav a[href^=\"#\"]").on "click", (event) ->
      target = $($(this).attr("href"))
      $('.nav li a.active').removeClass('active')
      $(this).addClass('active')
      if target.length
        event.preventDefault()
        $(this).tab('show')
      return
    return
$(document).ready on_load
