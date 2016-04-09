on_load = ->
  load
    controllers:
      spaces: ["new"]
  , (controller, action) ->
    initialize_selects = ->
      $('.space-types-select').select2()
      return
    initialize_listeners = ->
      $('.price-checkbox').change ->
        if !@checked
          $(this).closest('.row').find('input.price-input[type=number]').val ''
        return
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
      $('.form-group.has-error').removeClass 'has-error'
      checked_price = $('.price-checkbox').is(':checked')
      empty_prices = $('.price-checkbox:checked').closest('.row').find('input.price-input[type=number]').filter ->
        @value.length <= 0 || @value == 0
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

$(document).ready on_load
