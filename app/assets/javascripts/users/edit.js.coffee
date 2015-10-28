on_load = ->
  load
    controllers:
      users: ["edit"]
  , (controller, action) ->
    close_languages_modal = ->
      values = get_select2_languages()
      set_language_values_to_form(values)
      show_selected_languages(values)
      $('#languageModal').modal('hide')
    delete_language = (element) ->
      lang = element[0].dataset.lang
      values = delete_language_from_values(lang, get_select2_languages())
      $('#languages_spoken_select').val(values).trigger('change')
      set_language_values_to_form(values)
      $('#lang-item-'+lang).hide()

    delete_language_from_values = (lang, values)->
      i = values.length - 1
      while i >= 0
        if values[i] == lang
          values.splice i, 1
        i--
      return values
    set_language_values_to_form = (values) ->
      $('#user_languages_spoken').val(values)
      return
    get_select2_languages = () ->
      return $('#languages_spoken_select').val()
    show_selected_languages = (values) ->
      $('.lang-item').hide()
      if !values
        return
      index = 0
      len = values.length
      while index < len
        $('#lang-item-'+values[index]).show()
        ++index
      return

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
      $('.gender-select').select2({minimumResultsForSearch: -1})
      $('.language-select').select2()
      $('.profession-select').select2()
      $('.multi-lang-select').select2()

    initialize_listeners = ->
      $('#save-languages').click ->
        close_languages_modal()
      $('.delete-lang').click  ->
        delete_language($(this))
      $('#emergency-toggle').click ->
        $('.emergency-info').toggle()
      # handle avatar
      $('#avatar-link').click ->
        $('#user_avatar').click()
        $('#avatar-modal').modal('hide')
      $('#user_avatar').change ->
        handle_local_img('#user_avatar', '#user-avatar-img')

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
      $('#gender-popover').popover(options)
      $('#email-popover').popover(options)
      $('#phone-popover').popover(options)
      $('#emergency-popover').popover(options)
      $('#emergency_phone-popover').popover(options)
      $('#nationality-popover').popover(options)
      $('#country_of_residence-popover').popover(options)

    $("#phone").intlTelInput
      allowExtensions: true
      utilsScript: '/utils.js'

    $("#emergency_phone").intlTelInput
      allowExtensions: true
      utilsScript: '/utils.js'

    $('#save-edition').click ->
      $('#phone').val($('#phone').intlTelInput("getNumber"))

    new google.maps.places.Autocomplete(document.getElementById('user_location'))
    initialize_selects()
    initialize_listeners()
    initialize_popovers()
    show_selected_languages(get_select2_languages())
    $('.emergency-info').hide()
  return
$(document).ready on_load
