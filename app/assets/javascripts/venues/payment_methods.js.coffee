on_load = ->
  load
    controllers:
      venue_collection_accounts: ["collection_account_info", "edit_collection_account"]
  , (controller, action) ->

    initializeListeners = ->
      $('#tab-business').click ->
        $(this).addClass 'tab--selected'
        $('#tab-personal').removeClass 'tab--selected'
        $('.business-section').removeClass 'none'
      $('#tab-personal').click ->
        $(this).addClass 'tab--selected'
        $('#tab-business').removeClass 'tab--selected'
        $('.business-section').addClass 'none'
      $('.js-tab').click ->
        $('.js-tab').removeClass('tab--selected')
        $(this).addClass('tab--selected')
        type = $(this).attr('data-type')
        if type
          changeLegalPersonType(type)
          showAccountTypeFieldAndEraseTheOthers(type)

    showAccountTypeFieldAndEraseTheOthers = (type) ->
      if type
        $('.js-account-field').not(".js-" + type.toLowerCase()).addClass('none').find('input').val('')
        $('.js-account-field.js-' + type.toLowerCase()).removeClass('none')
    changeLegalPersonType = (type) ->
      $('#mangopay_collection_account_bank_type').val(type)

    initializePopovers = ->
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
      $('.lock-popover').popover(options)

    initializePopovers()
    initializeListeners()
    showAccountTypeFieldAndEraseTheOthers($('#mangopay_collection_account_bank_type').val())

$(document).ready on_load
