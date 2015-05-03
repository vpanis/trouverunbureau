timeBetweenRetrievesMS = 1000
on_load = ->
  paymentId = $("#hidden-data")[0].dataset.paymentId
  setTimeout (->
    retrieve_token paymentId
    return
  ), timeBetweenRetrievesMS
retrieve_token = (paymentId) ->
  $.ajax
    url: '/api/v1/braintree/customer_nonce_token?payment_id=' + paymentId
    success: (response) ->
      if response.token == null || response.token.trim() == ''
        setTimeout (->
          retrieve_token paymentId
          return
        ), timeBetweenRetrievesMS
      else
        braintree.setup response.token, 'dropin', { container: 'js-dropin' }
$(document).ready on_load
