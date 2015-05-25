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

    checkStep = (endpoint, context) ->
      $.ajax({
        url: BASEURL + endpoint
        success: (response) ->
          if response.done == true
            $(context).addClass('done')
      })

    checkStep('first_step', $('.verification-list li')[0])
    checkStep('second_step', $('.verification-list li')[1])
    checkStep('third_step', $('.verification-list li')[2])
    checkStep('fourth_step', $('.verification-list li')[3])
    checkStep('fifth_step', $('.verification-list li')[4])
    checkStep('sixth_step', $('.verification-list li')[5])

    $.ajax({
      url: BASEURL + 'percentage'
      success: (response)->
        percentage = parseInt(response.percentage).toString()
        $('.progress-container .progress').width(percentage + '%')
        $('.progress-counter').text(percentage + '%')
    })

$(document).ready on_load
