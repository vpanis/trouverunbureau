on_load = ->
  $.ajax
    url: '/api/v1/braintree/current_represented_customer_token'
    success: (response) ->
      braintree.setup response.token, 'dropin', { container: 'js-dropin' }
$(document).ready on_load