on_load = ->
  $.ajax
    url: 'api/v1/mongopay/configuration'
    success: (response) ->
      mangoPay.cardRegistration.baseURL = response.config.base_url
      mangoPay.cardRegistration.clientId = response.config.client_id

$(document).ready on_load
