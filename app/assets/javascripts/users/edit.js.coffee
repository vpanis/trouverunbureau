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


    initialize_selects = ->
      $('.gender-select').select2({minimumResultsForSearch: -1})
      $('.language-select').select2({minimumResultsForSearch: -1})
      $('.profession-select').select2({minimumResultsForSearch: -1})
      $('.multi-lang-select').select2({minimumResultsForSearch: -1})

    initialize_listeners = ->
      $('#save-languages').click ->
        close_languages_modal()
      $('.delete-lang').click  ->
        delete_language($(this))

    initialize_selects()
    initialize_listeners()
    show_selected_languages(get_select2_languages())
  return
$(document).ready on_load
