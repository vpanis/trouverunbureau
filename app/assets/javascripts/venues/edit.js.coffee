on_load = ->
  load
    controllers:
      venues: ["edit"]
  , (controller, action) ->
    initialize_selects = ->
      $('.venue-types-select').select2({minimumResultsForSearch: -1})
      $('.currency-select').select2({minimumResultsForSearch: -1})

    initialize_listeners = ->
      return

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

    initialize_selects()
    initialize_listeners()
    initialize_popovers()
  return
$(document).ready on_load
