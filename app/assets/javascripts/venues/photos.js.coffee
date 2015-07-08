on_load = ->
  load
    controllers:
      venues: ["photos"]
  , (controller, action) ->

    $('#save-photos').click (event) ->
      # there is always one child because of the upload form
      if($('.row.pictures').children().size() < 2)
        event.preventDefault()
        $('.row.pictures').prepend('<div class="photo-errors"> You must add at least one picture </div>')


    add_photo = (data) ->
      photo_html = "<div class=\"col-md-4\"><div class=\"img-wrapper\" style=\"background-image: url("+data.photo+");\"><div class=\"hover\"><a class=\"delete-photo\" data-photo-id=\""+data.id+"\" href=\"#\">delete</a></div></div></div>"
      $('.add-image-container').before(photo_html)
      $('.delete-photo').unbind('click')
      $('.delete-photo').click (event) ->
        delete_photo(event, this)
    delete_photo = (event, element) ->
      event.preventDefault()
      photoId = element.dataset.photoId
      if photoId == 'undefined' || photoId == null || photoId == ''
        return
      show_spinner()
      $.ajax
        type: 'DELETE'
        url: '/api/v1/venue_photos/'+photoId
        cache: false
        contentType: false
        processData: false
        context: element
        success: (data) ->
          hide_spinner()
          element.parentElement.parentElement.parentElement.remove()
          return
        error: (data) ->
          hide_spinner()
          console.log(data)
          return
      return

    initialize_listeners = ->
      $('.delete-photo').click (event) ->
        delete_photo(event, this)
      $('.add-image').click ->
        $('#photo').click()
      $('#photo').change ->
        if typeof this.value == 'undefined' || this.value == null || this.value == ''
          return
        $('#venue-photo-form').submit()
      $('#venue-photo-form').on 'submit', (e) ->
        e.preventDefault()
        formData = new FormData(this)
        show_spinner()
        $.ajax
          type: 'POST'
          url: $(this).attr('action')
          data: formData
          cache: false
          contentType: false
          processData: false
          success: (data) ->
            hide_spinner()
            add_photo(data)
            return
          error: (data) ->
            hide_spinner()
            console.log data
            return
        return

    initialize_listeners()

  return
$(document).ready on_load
