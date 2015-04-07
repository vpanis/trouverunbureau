on_load = ->
  load
    controllers:
      spaces: ["index"]
  , (controller, action) ->
    initialize_listeners = ->
      $('.filter-button').click ->
        show_filters_form()
      $('#formCross').click ->
        close_filters_form()
      $('#show_filters').click ->
        close_filters_form()
      $('.open-footer').click ->
        $('#footer').toggleClass 'open'
    show_filters_form = ->
      $('#filtersForm').addClass('visible')
    close_filters_form = ->
      $('#filtersForm').removeClass('visible')

    set_content_height = ->
      viewportH = $(window).height()
      navbarH = $('.navbar').outerHeight()
      filterBoxH = $('.filter-box').outerHeight()
      $('#map-canvas').height viewportH - navbarH
      $('.spaces-results').height viewportH - navbarH - filterBoxH



    initialize_listeners()
    set_content_height()
$(document).ready on_load
