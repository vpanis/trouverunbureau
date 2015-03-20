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
        return
    show_filters_form = ->
      $('.filter-box').removeClass('fixed-box')
      $('#countResultsBox').hide()
      $('#filtersForm').show()
    close_filters_form = ->
      $('#filtersForm').hide()
      $('.filter-box').addClass('fixed-box')
      $('#countResultsBox').show()

    set_content_height = ->
      viewportH = $(window).height()
      navbarH = $('.navbar').outerHeight()
      filterBoxH = $('.filter-box').outerHeight()
      console.log filterBoxH
      $('#map-canvas').height viewportH - navbarH
      $('.spaces-results').height viewportH - navbarH - filterBoxH
      return

    initialize_listeners()
    set_content_height()
$(document).ready on_load
