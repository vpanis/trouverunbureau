on_load = ->
  load
    controllers:
      spaces: ["edit"]
  , (controller, action) ->

    $('#save-space').click (event) ->
      # there is always one child because of the upload form
      if($('.row.pictures').children().size() < 2)
        event.preventDefault()
        $('.row.pictures').prepend('<div class="photo-errors"> You must add at least one picture </div>')

    add_photo = (data) ->
      photo_html = "<div class=\"col-md-4\"><div class=\"img-wrapper\" style=\"background-image: url("+data.photo+");\"><div class=\"hover\"><a class=\"delete-photo\" data-photo-id=\""+data.id+"\" data-space-id=\""+data.space_id+"\" href=\"#\">delete</a></div></div></div>"
      $('.add-image-container').before(photo_html)
      $('.delete-photo').unbind('click')
      $('.delete-photo').click (event) ->
        delete_photo(event, this)
    delete_photo = (event, element) ->
      event.preventDefault()
      photoId = element.dataset.photoId
      spaceId = parseInt(element.dataset.spaceId)
      if photoId == 'undefined' || photoId == null || photoId == ''
        return
      show_spinner()
      $.ajax
        type: 'DELETE'
        url: '/api/v1/venue_photos/'+photoId
        cache: false
        context: element
        dataType: "json"
        data: { space_id: spaceId }
        success: (data) ->
          hide_spinner()
          element.parentElement.parentElement.parentElement.remove()
          return
        error: (data) ->
          hide_spinner()
          console.log(data)
          return
      return
    initialize_selects = ->
      $('.space-types-select').select2()
      return
    initialize_listeners = ->
      $('.price-checkbox').change ->
        if !@checked
          $(this).closest('.row').find('input.price-input[type=number]').val ''
        return
      $('.edit_space').submit ->
        validate_price()
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
      $('#capacity-popover').popover(options)
      $('#quantity-popover').popover(options)
      $('#description-popover').popover(options)
      $('#photos-popover').popover(options)
      $('#price-popover').popover(options)
      $('#deposit-popover').popover(options)

    validate_price = ->
      $('.form-group.has-error').removeClass 'has-error'
      checked_price = $('.price-checkbox').is(':checked')
      empty_prices = $('.price-checkbox:checked').closest('.row').find('input.price-input[type=number]').filter ->
        @value.length <= 0
      valid_price = !empty_prices || empty_prices.length == 0

      return true if checked_price && valid_price
      showErrorMessage(empty_prices)
      false

    showErrorMessage = (empty_prices) ->
      if empty_prices
        empty_prices.each ->
          $(this).closest('.form-group').addClass 'has-error'
          return
      else
        $('.pricing .form-group').addClass 'has-error'
      return

    initialize_selects()
    initialize_listeners()
    initialize_popovers()

  return
$(document).ready on_load
