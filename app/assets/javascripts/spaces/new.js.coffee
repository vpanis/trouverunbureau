on_load = ->
  load
    controllers:
      spaces: ["new"]
  , (controller, action) ->
    initialize_selects = ->
      $('.space-types-select').select2()
      return
    initialize_listeners = ->
      $('#new_space').submit ->
        validate_price()

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
          "top"
      }
      $('#capacity-popover').popover(options)
      $('#quantity-popover').popover(options)
      $('#description-popover').popover(options)
      $('#photos-popover').popover(options)
      $('#price-popover').popover(options)
      $('#deposit-popover').popover(options)

    validate_price = ->
      checked_price = $('.price-checkbox').is(':checked')
      values = $.map($('.price-checkbox:checked').closest('.row').find('input[type=number]'),
        (e) -> $(e).val())
      valid_price = $.inArray("", values) != 1
      return true if checked_price && valid_price
      showErrorMessage()
      false

    showErrorMessage = ->
      $('.pricing .form-group').addClass 'has-error'

    initialize_selects()
    initialize_listeners()
    initialize_popovers()

$(document).ready on_load
