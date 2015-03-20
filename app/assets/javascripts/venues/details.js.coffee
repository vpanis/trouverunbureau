on_load = ->
  load
    controllers:
      venue_details: ["details"]
  , (controller, action) ->
    initialize_selects = ->
      $('.hour-select').select2()

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
        enable_disable_day(this.checked, this.dataset.index)
      $('.fake-open-day').change ->
        handle_std_open_day(this)
      $('.fake-hour-select').change ->
        handle_std_hour_select(this)

    handle_std_open_day = (element) ->
      weekday = element.dataset.weekday
      if weekday == 'weekday'
        i = 0
        while i < 5
          toggleCustomChecked(i, element.checked, weekday)
          i++
      else
        toggleCustomChecked(element.dataset.index, element.checked, weekday)
      return

    handle_std_hour_select = (element) ->
      weekday = element.dataset.weekday
      if weekday == 'weekday'
        i = 0
        while i < 5
          triggerCustomValue(i, weekday, element.value, element.dataset.fromTo)
          i++
      else
        triggerCustomValue(element.dataset.index, weekday, element.value, element.dataset.fromTo)
      return

    triggerCustomValue = (index, weekday, value, from_to) ->
      if is_closed(index)
        $('#open_'+index).attr('checked', true).trigger('change')
        enable_disable_day(true, index)
        if from_to == 'from'
          $('#venue_day_hours_attributes_'+index+'_to').val($('#to_'+weekday).val()).trigger('change')
        else
          $('#venue_day_hours_attributes_'+index+'_from').val($('#from_'+weekday).val()).trigger('change')
      $('#venue_day_hours_attributes_'+index+'_'+from_to).val(value).trigger('change')
      return

    toggleCustomChecked = (index, open, fake_day) ->
      $('#open_'+index).attr('checked', open).trigger('change')
      enable_disable_day(open, index)
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

    is_closed = (index) ->
      !($('#open_'+index)[0].checked)

    initialize_closed_days = ->
      initialize_custom_closed_days()
      initialize_standard_closed_days()
      return

    initialize_custom_closed_days = ->
      days = $('.open-day')
      i = 0
      while i < days.length
        enable_disable_day(days[i].checked, days[i].dataset.index)
        i++
      return

    initialize_standard_closed_days = ->
      fake_days = $('.fake-open-day')
      i = 0
      while i < fake_days.length
        field = fake_days[i]
        if field.checked
          $('#from_'+field.dataset.weekday).prop('disabled', false)
          $('#to_'+field.dataset.weekday).prop('disabled', false)
        else
          $('#from_'+field.dataset.weekday).prop('disabled', 'disabled')
          $('#to_'+field.dataset.weekday).prop('disabled', 'disabled')
        i++
      return

    enable_disable_day = (open, index) ->
      if open
        $('#venue_day_hours_attributes_'+index+'__destroy').attr('checked', false)
        $('#venue_day_hours_attributes_'+index+'_from').prop('disabled', false)
        $('#venue_day_hours_attributes_'+index+'_to').prop('disabled', false)
      else
        $('#venue_day_hours_attributes_'+index+'__destroy').attr('checked', true)
        $('#venue_day_hours_attributes_'+index+'_from').prop('disabled', 'disabled')
        $('#venue_day_hours_attributes_'+index+'_to').prop('disabled', 'disabled')
      return

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
    initialize_closed_days()
  return
$(document).ready on_load
