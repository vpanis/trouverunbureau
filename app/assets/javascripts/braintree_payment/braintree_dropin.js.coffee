on_load = ->
  setTimeout retrieve_token, 1000;
retrieve_token = ->
  $.ajax
    url: '/api/v1/braintree/current_represented_customer_token'
    success: (response) ->
      if response.token == null
        setTimeout retrieve_token, 1000;
      else
        braintree.setup response.token, 'dropin', { container: 'js-dropin' }
$(document).ready on_load
