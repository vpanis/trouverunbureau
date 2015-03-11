on_load = ->
  load
    controllers:
      venues: ["search"]
  , (controller, action) ->
    initialize_listeners = ->
      $('.filter-button').click ->
        show_filters_form()
      $('#formCross').click ->
        close_filters_form()
    show_filters_form = ->
      $('#filtersForm').show('slow')
      $('.filter-box').removeClass('fixed-box')
    close_filters_form = ->
      $('#filtersForm').hide()
      $('.filter-box').addClass('fixed-box')
    initialize_listeners()
$(document).ready on_load
