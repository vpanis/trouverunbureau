timeBetweenRetrievesMS = 1000
on_load = ->
  paymentId = $("#hidden-data")[0].dataset.paymentId
  setTimeout (->
    retrieve_token paymentId
    return
  ), timeBetweenRetrievesMS
retrieve_token = (paymentId) ->
  show_spinner()
  $.ajax
    url: '/api/v1/braintree/customer_nonce_token?payment_id=' + paymentId
    success: (response) ->
      hide_spinner()
      if response.token == null || response.token.trim() == ''
        setTimeout (->
          retrieve_token paymentId
          return
        ), timeBetweenRetrievesMS
      else
        hide_spinner()
        braintree.setup response.token, 'dropin', { container: 'js-dropin' }
$(document).ready on_load
