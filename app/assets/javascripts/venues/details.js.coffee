on_load = ->
  load
    controllers:
      venue_details: ["details"]
  , (controller, action) ->
    initialize_selects = ->
      return
    # $('.venue-types-select').select2({minimumResultsForSearch: -1})
    #$('.currency-select').select2({minimumResultsForSearch: -1})

    initialize_listeners = ->
      $('#all-professions').click ->
        handle_all_professions(this)
      $('#save-professions').click ->
        close_professions_modal()
      $('#professionModal').on 'show.bs.modal', (element) ->
        if belongsToArray(element.relatedTarget.classList, 'disabled')
          element.preventDefault()
      $('.delete-lang').click  ->
        delete_profession($(this))

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

    belongsToArray = (array, value) ->
      i = 0
      while i < array.length
        if array[i] == value
          return true
        i++
      false

    handle_all_professions = (element) ->
      if element.checked
        $('#venue_professions').val("")
        $('#open-professions').addClass('disabled')
        show_selected_professions()
      else
        $('#open-professions').removeClass('disabled')
        set_profession_values()

    close_professions_modal = ->
      set_profession_values()
      $('#professionModal').modal('hide')
      return

    set_profession_values = ->
      options = $('.selected-profession-option')
      values = []
      i = 0
      while i < options.length
        option = options[i]
        if option.checked
          values.push(option.value)
        i++
      $('#venue_professions').val(values.join())
      show_selected_professions()

    delete_profession = (element) ->
      prof = element[0].dataset.prof
      $('#selected_professions_'+prof).attr('checked', false)
      set_profession_values()

    show_selected_professions = ->
      value = $('#venue_professions').val().replace(/{|}/g, "")
      values = value.split(',')
      $('.lang-item').hide()
      if !values
        return
      index = 0
      len = values.length
      while index < len
        $('#prof-item-'+values[index]).show()
        ++index
      return

    initialize_selects()
    initialize_listeners()
    initialize_popovers()
    show_selected_professions()
  return
$(document).ready on_load
