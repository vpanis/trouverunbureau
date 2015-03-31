timeBetweenRetrievesMS = 1000
selectedCreditCardId = null
on_load = ->
  $.ajax
    url: '/api/v1/mangopay/configuration'
    success: (response) ->
      mangoPay.cardRegistration.baseURL = response.config.base_url
      mangoPay.cardRegistration.clientId = response.config.client_id
  $('#js-create-card-registration').on 'click', (event) ->
    $("#new-credit-card").addClass("loading")
    create_new_card_registration $('#js-card_currency').val().toUpperCase()
  $('.js-credit-card').on 'click', select_card

select_card = (event) ->
  selectedCreditCardId = this.dataset.creditCardId
  $('.js-credit-card').removeClass('active')
  $("#js-card-info").removeClass('active')
  $(this).addClass('active')
  return

create_new_card_registration = (currency) ->
  $.ajax
    url: '/api/v1/mangopay/card_registration'
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
    url: '/api/v1/mangopay/new_card_info?mangopay_credit_card_id=' + credit_card_id
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
        $("#new-credit-card").removeClass("loading")
        $("#js-card-pre-registration-data").remove()
        $("#js-card-info").removeClass("hidden")
        $('#js-create-credit-card').on 'click', (event) ->
          save_new_card(credit_card_id)

save_new_card = (credit_card_id) ->
  $("#required-label").addClass("hidden")
  non_empty_val = _.reduce $('#js-card-info input'), ((acc, input) ->
    acc and $(input).val() != ''
  ), true
  if !non_empty_val
    $("#required-label").removeClass("hidden")
    return
  $("#new-credit-card").addClass("loading")
  cardData =
    cardNumber: $("#js-card_number").val()
    cardExpirationDate: $("#js-card_exp_date_month").val() + $("#js-card_exp_date_year").val()
    cardCvx: $("#js-card_cvx").val()
    cardType: $("#js-card_type").val()

  $("#js-card-info :input").attr('disabled', true)
  mangoPay.cardRegistration.registerCard cardData, ((response) ->
    # Success, you can use res.CardId now that points to registered card
    $.ajax
      url: '/api/v1/mangopay/save_credit_card'
      method: 'PUT'
      data:
        mangopay_credit_card:
          id: credit_card_id
          credit_card_id: response.CardId
          last_4: cardData.cardNumber.substring(cardData.cardNumber.length - 4)
          expiration: cardData.cardExpirationDate
          card_type: cardData.cardType
      success: (response) ->
        $("#new-credit-card").removeClass("loading")
        $('.js-credit-card').removeClass('active')
        $("#js-card-info").addClass('active')
        $("#js-create-credit-card").remove()
        return
      error: (response) ->
        $("#new-credit-card").removeClass("loading")
        console.log(response)

    return
  ), (response) ->
    $("#js-card-info :input").attr('disabled', false)
    # Handle error, see res.ResultCode and res.ResultMessage
    return

# pay = (card_id) ->

$(document).ready on_load
