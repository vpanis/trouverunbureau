on_load = ->
  load
    controllers:
      venues: ["new","edit"]
  , (controller, action) ->
    handle_local_img = (form_img_selector, img_selector) ->
      input = $(form_img_selector)
      if input[0] and input[0].files[0]
        reader = new FileReader()
        reader.onload = (e) ->
          load_img_preview(img_selector, e.target.result)
          $(form_img_selector)[0].files[0] = e.target.result;
          return
        reader.readAsDataURL input[0].files[0]

    load_img_preview = (selector, remote_url) ->
      if $(selector)[0] is undefined
        return
      $(selector).attr('src', remote_url)

    initialize_selects = ->
      $('.country-select').select2()

    initialize_listeners = ->
      # handle avatar
      $('#logo-link').click ->
        $('#venue_logo').click()
        $('#logo-modal').modal('hide')
      $('#venue_logo').change ->
        handle_local_img('#venue_logo', '#venue-logo-img')

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
      return
      #$('#emergency-popover').popover(options)

    initialize_selects()
    initialize_listeners()
    initialize_popovers()
  return
$(document).ready on_load
