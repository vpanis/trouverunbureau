on_load = ->
  load
    controllers:
      venue_details: ["details"]
  , (controller, action) ->
    initialize_selects = ->
      $('.hour-select').select2()
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
      $('.open-day').change ->
        handle_day_checked(this.checked, this.dataset.index)
      $('.fake-open-day').change ->
        handle_fake_open_day(this)
      $('.fake-hour-select').change ->
        handle_fake_hour_select(this)

    handle_fake_open_day = (element) ->
      weekday = element.dataset.weekday
      if weekday == 'weekday'
        i = 0
        while i < 5
          toggleCustomChecked(i, element.checked, weekday)
          i++
      else
        toggleCustomChecked(element.dataset.index, element.checked, weekday)
      return

    handle_fake_hour_select = (element) ->
      weekday = element.dataset.weekday
      from_to = element.dataset.fromTo
      if weekday == 'weekday'
        i = 0
        while i < 5
          triggerCustomValue(i, element.value, from_to)
          i++
      else
        triggerCustomValue(weekday, element.value, from_to)
      return

    triggerCustomValue = (index, value, from_to) ->
      $('#venue_day_hours_attributes_'+index+'_'+from_to).val(value).trigger('change')

    toggleCustomChecked = (index, open, fake_day) ->
      $('#open_'+index).attr('checked', open).trigger('change')
      handle_day_checked(open, index)
      if open
        $('#from_'+fake_day).prop('disabled', false)
        $('#to_'+fake_day).prop('disabled', false)
      else
        $('#from_'+fake_day).prop('disabled', 'disabled')
        $('#to_'+fake_day).prop('disabled', 'disabled')

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

    disable_closed_days = ->
      days = $('.open-day')
      i = 0
      while i < days.length
        handle_day_checked(days[i].checked, days[i].dataset.index)
        i++
      return

    handle_day_checked = (open, index) ->
      if open
        $('#venue_day_hours_attributes_'+index+'__destroy').attr('checked', false)
        $('#venue_day_hours_attributes_'+index+'_from').prop('disabled', false)
        $('#venue_day_hours_attributes_'+index+'_to').prop('disabled', false)
      else
        $('#venue_day_hours_attributes_'+index+'__destroy').attr('checked', true)
        $('#venue_day_hours_attributes_'+index+'_from').prop('disabled', 'disabled')
        $('#venue_day_hours_attributes_'+index+'_to').prop('disabled', 'disabled')

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
    disable_closed_days()
  return
$(document).ready on_load
