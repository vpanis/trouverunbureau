on_load = ->
  load
    controllers:
      venue_collection_accounts: ["collection_account_info"]
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
      $('#legal-name-popover').popover(options)
      $('#tax-id-popover').popover(options)
      $('#first-name-popover').popover(options)
      $('#email-popover').popover(options)
      $('#last-name-popover').popover(options)
      $('#ssn-popover').popover(options)
      $('#street-popover').popover(options)
      $('#locality-popover').popover(options)
      $('#region-popover').popover(options)
      $('#postal-code-popover').popover(options)
      $('#birth-of-date-popover').popover(options)
      $('#account-number-code-popover').popover(options)
      $('#routing-number-popover').popover(options)


    initialize_popovers()
    initialize_listeners()

$(document).ready on_load
