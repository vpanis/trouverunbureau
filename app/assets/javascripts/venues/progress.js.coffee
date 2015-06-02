on_load = ->
  load
    controllers:
      venues: ['edit', 'update', 'photos', 'spaces']
      venue_amenities: ['amenities', 'save_amenities']
      venue_collection_accounts: ['collection_account_info', 'edit_collection_account']
      venue_details: ['details', 'save_details']
      spaces: ['new', 'edit']
  , (controller, action) ->

    id = $('.verification-list a').attr('href').split('/')[2]
    BASEURL = '/api/v1/venues/' + id + '/'
    publishEnabled = false

    checkStatus = (callback) ->
      $.ajax({
        url: BASEURL + 'status'
        success: (response) ->
          callback(response)
      })

    addTicks = (response) ->
      $($('.verification-list li')[0]).addClass('done') if response.first_step
      $($('.verification-list li')[1]).addClass('done') if response.second_step
      $($('.verification-list li')[2]).addClass('done') if response.third_step
      $($('.verification-list li')[3]).addClass('done') if response.fourth_step
      $($('.verification-list li')[4]).addClass('done') if response.fifth_step
      $($('.verification-list li')[5]).addClass('done') if response.sixth_step

    setPercentage = (response) ->
      percentage = parseInt(response.percentage).toString()
      $('.progress-container .progress').width(percentage + '%')
      $('.progress-counter').text(percentage + '%')
      if percentage == "100"
        $('.status-text span').text('Complete')
        $('.status-text span').css('color: green;')
      else
        $('.status-text span').text('Incomplete')
        $('.status-text span').css('color: red;')

    canPublish = (stepsStatus) ->
      publishEnabled = stepsStatus.first_step && stepsStatus.second_step && stepsStatus.third_step &&
      stepsStatus.fourth_step && stepsStatus.fifth_step && stepsStatus.sixth_step
      return publishEnabled

    enablePublishIfPossible = (response) ->
      if canPublish(response)
        $('#publish-container input').css('background-color', '#ffe111')
        $('#publish-container input').css('border-color', '#ffe111')

    $('#publish-venue').submit((event) ->
      event.preventDefault() if !publishEnabled
    )

    checkStatus((response) ->
      addTicks(response)
      setPercentage(response)
      enablePublishIfPossible(response)
    )

$(document).ready on_load
