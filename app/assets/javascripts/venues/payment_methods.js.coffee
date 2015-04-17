on_load = ->
  load
    controllers:
      venues: ["payment_methods"]
  , (controller, action) ->

    initialize_listeners = ->
      $('#tab-business').click ->
        $(this).toggleClass 'tab--selected'
        $('#tab-personal').toggleClass 'tab--selected'
        $('.business-section').toggleClass 'none'
      $('#tab-personal').click ->
        $(this).toggleClass 'tab--selected'
        $('#tab-business').toggleClass 'tab--selected'
        $('.business-section').toggleClass 'none'
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
      $('#first-name-popover').popover(options)
      $('#email-popover').popover(options)
      $('#last-name-popover').popover(options)
      $('#ssn-popover').popover(options)
      $('#street-popover').popover(options)

    initialize_popovers()
    initialize_listeners()

$(document).ready on_load
