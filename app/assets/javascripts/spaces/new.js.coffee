on_load = ->
  load
    controllers:
      spaces: ["new"]
  , (controller, action) ->
    initialize_selects = ->
      $('.space-types-select').select2({minimumResultsForSearch: -1})
      return
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
      # $('#one-popover').popover(options)
      return

    initialize_selects()
    initialize_listeners()
    initialize_popovers()

  return
$(document).ready on_load
