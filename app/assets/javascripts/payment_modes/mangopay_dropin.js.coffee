timeBetweenRetrievesMS = 1000

on_load = ->
  $.ajax
    url: 'api/v1/mangopay/configuration'
    success: (response) ->
      mangoPay.cardRegistration.baseURL = response.config.base_url
      mangoPay.cardRegistration.clientId = response.config.client_id

create_new_card_registration = (currency) ->
  $.ajax
    url: 'api/v1/mangopay/card_registration'
    method: 'POST'
    data:
      currency: currency
    success: (response) ->
      setTimeout (->
        retrieve_new_card_info response.mangopay_credit_card_id
        return
      ), timeBetweenRetrievesMS

retrieve_new_card_info = (credit_card_id) ->
  $.ajax
    url: 'api/v1/mangopay/new_card_info?mangopay_credit_card_id=' + credit_card_id
    success: (response) ->
      if response == null
        setTimeout (->
          retrieve_new_card_info credit_card_id
          return
        ), timeBetweenRetrievesMS
      else
        mangoPay.cardRegistration.init
          cardRegistrationURL: response.card_registration_url
          preregistrationData: response.pre_registration_data
          accessKey: response.registration_access_key
          Id: response.registration_id
        $("#js-card_info").removeClass("hidden")

save_new_card = ->
  cardData =
    cardNumber: $("#js-card_number").val(),
    cardExpirationDate: $("#cjs-ard_exp_date_month").val() + $("#js-card_exp_date_year").val(),
    cardCvx: $("#js-card_cvx").val(),
    cardType: $("#js-card_type").val()

    mangoPay.cardRegistration.registerCard cardData, ((response) ->
      # Success, you can use res.CardId now that points to registered card
      $.ajax
        url: 'api/v1/mangopay/save_credit_card'
        method: 'POST'
        data:
          credit_card_id: response.CardId
          last_4: cardData.cardNumber.substring(cardData.cardNumber.length - 4)
          expiration: cardData.cardExpirationDate
          card_type: cardData.cardType
      return
    ), (response) ->
      # Handle error, see res.ResultCode and res.ResultMessage
      return

pay_with_card_id = (card_id) ->


$(document).ready on_load
