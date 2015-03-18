on_load = ->
  load
    controllers:
      reviews: ["new_client_review", "new_venue_review"]
  , (controller, action) ->

    initialize_listeners = ->
      $('.bigstar').click ->
        index = this.dataset.index
        set_rating(index)
        show_hide_stars(index)
        return

    set_rating = (index) ->
      $('#client_review_stars').val(index)

    show_hide_stars = (index) ->
      stars = $('.bigstar')
      stars.removeClass('active')
      i = 0
      while i < index
        $(stars[i]).addClass('active')
        i++
      return

    initialize_listeners()

  return
$(document).ready on_load
