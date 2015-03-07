on_load = ->
  load
    controllers:
      spaces: ["edit"]
  , (controller, action) ->
    add_photo = (data) ->
      photo_html = "<div class=\"col-md-4\"><div class=\"img-wrapper\" style=\"background-image: url("+data.photo+");\"><div class=\"hover\"><a class=\"delete\" data-photo-id=\""+data.id+"\" href=\"#\">delete</a></div></div></div>"
      $('.add-image-container').before(photo_html)
    initialize_selects = ->
      $('.space-types-select').select2({minimumResultsForSearch: -1})
      return
    initialize_listeners = ->
      $('.add-image').click ->
        $('#photo').click()
      $('#photo').change ->
        if typeof this.value == 'undefined' || this.value == null || this.value == ''
          return
        $('#venue-photo-form').submit()
      $('#venue-photo-form').on 'submit', (e) ->
        e.preventDefault()
        formData = new FormData(this)
        $.ajax
          type: 'POST'
          url: $(this).attr('action')
          data: formData
          cache: false
          contentType: false
          processData: false
          success: (data) ->
            console.log data
            add_photo(data)
            return
          error: (data) ->
            console.log data
            return
        return

    initialize_popovers = ->
      options = {
        placement: (context, source) ->
          position = $(source).offset()
          if (position.left > 160)
              return "left"
          if (position.left < 160)
              return "right"
          if (position.top < 110)
              return "bottom"
          return "top"
      }
      # $('#one-popover').popover(options)
      return

    initialize_selects()
    initialize_listeners()
    initialize_popovers()

  return
$(document).ready on_load
