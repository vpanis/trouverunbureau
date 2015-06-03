on_load = ->
  load
    controllers:
      organizations: ["edit"]
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

    initialize_listeners = ->
      # handle avatar
      $('#avatar-link').click ->
        $('#organization_logo').click()
        $('#avatar-modal').modal('hide')
      $('#organization_logo').change ->
        handle_local_img('#organization_logo', '#user-avatar-img')
      $('#add-manager-link').click ->
        $('#add-manager-modal').modal('hide')
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
      $('#last-name-popover').popover(options)
      $('#email-popover').popover(options)
      $('#phone-popover').popover(options)

    $("#phone").intlTelInput
      allowExtensions: true
      utilsScript: '/utils.js'
    $("#phone").intlTelInput("setNumber", $('#organization_phone').val());

    $('#save-organization').click ->
      $('#organization_phone').val($('#phone').intlTelInput("getNumber"))
    initialize_listeners()
    initialize_popovers()
  return
$(document).ready on_load
