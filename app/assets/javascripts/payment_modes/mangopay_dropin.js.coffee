timeBetweenRetrievesMS = 1000
selectedCreditCardId = null
onLoad = ->
  mangopayConfiguration = $("#js-mangopay-config")[0].dataset
  mangoPay.cardRegistration.baseURL = mangopayConfiguration.baseUrl
  mangoPay.cardRegistration.clientId = mangopayConfiguration.clientId
  $('#js-create-card-registration').on 'click', (event) ->
    $("#new-credit-card").addClass("loading")
    createNewCardRegistration $('#js-card_currency').val().toUpperCase()
  $('.js-credit-card').on 'click', select_card
  $('#js-pay').on 'click', (event) ->
    if selectedCreditCardId != null
      pay(selectedCreditCardId)
  # If the payment is in a expected response status
  bookingPaymentData = $("#hidden-data")[0].dataset
  if bookingPaymentData.bookingState == "payment_verification" and
    (bookingPaymentData.paymentState == 'EXPECTING_RESPONSE' or
      bookingPaymentData.paymentState == 'PAYING_CREATED')
    disableCardSelection()
    retrievePaymentInfo(bookingPaymentData.paymentId)

select_card = (event) ->
  selectedCreditCardId = this.dataset.creditCardId
  $('.js-credit-card').removeClass('active')
  $("#js-card-info").removeClass('active')
  $(this).addClass('active')
  $("#payment").removeClass('hidden')
  return

createNewCardRegistration = (currency) ->
  selectedCreditCardId = null
  $('.js-credit-card').removeClass('active')
  $.ajax
    url: '/api/v1/mangopay/card_registration'
    method: 'POST'
    data:
      currency: currency
    success: (response) ->
      setTimeout (->
        retrieveNewCardInfo response.mangopay_credit_card_id
        return
      ), timeBetweenRetrievesMS

retrieveNewCardInfo = (creditCardId) ->
  $.ajax
    url: '/api/v1/mangopay/new_card_info?mangopay_credit_card_id=' + creditCardId
    success: (response) ->
      if response == null
        setTimeout (->
          retrieveNewCardInfo creditCardId
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
          saveNewCard(creditCardId)

saveNewCard = (creditCardId) ->
  $(".js-card-errors").addClass("hidden")
  $("#required-label").addClass("hidden")
  nonEmptyVal = _.reduce $('#js-card-info input'), ((acc, input) ->
    acc and $(input).val() != ''
  ), true
  if !nonEmptVal
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
          id: creditCardId
          credit_card_id: response.CardId
          last_4: cardData.cardNumber.substring(cardData.cardNumber.length - 4)
          expiration: $("#js-card_exp_date_month").val() + '/' + $("#js-card_exp_date_year").val()
          card_type: cardData.cardType
      success: (response) ->
        $("#new-credit-card").removeClass("loading")
        $("#js-card-info").addClass('active').attr('data-credit-card-id', creditCardId).on 'click', select_card
        $("#js-create-credit-card").remove()
        selectedCreditCardId = creditCardId
        return
      error: (response) ->
        $("#new-credit-card").removeClass("loading")
        $("#js-card-info :input").attr('disabled', false)
        console.log(response)

    return
  ), (response) ->
    $("#new-credit-card").removeClass("loading")
    $("#js-card-info :input").attr('disabled', false)
    switch response.ResultCode
      when "105202"
        $(".js-card-format").removeClass("hidden")
      when "105203"
        $(".js-expiration-format").removeClass("hidden")
      when "105204"
        $(".js-cvx-format").removeClass("hidden")
    # Handle error, see res.ResultCode and res.ResultMessage
    return

disableCardSelection = ->
  $("#js-pay").attr('disabled', true)
  $('.js-credit-card').attr('disabled', true)
  $("#js-card-info").attr('disabled', true)

pay = (card_id) ->
  disableCardSelection()
  bookingId = $("#hidden-data")[0].dataset.bookingId
  $.ajax
    url: '/api/v1/mangopay/start_payment'
    method: 'PUT'
    data:
      booking_id: bookingId
      card_id: selectedCreditCardId
    success: (response) ->
      setTimeout (->
        retrievePaymentInfo response.mangopay_payment.id
        return
      ), timeBetweenRetrievesMS

retrievePaymentInfo = (paymentId) ->
  $.ajax
    url: '/api/v1/mangopay/payment_info?payment_id=' + paymentId
    success: (response) ->
      if response == null
        setTimeout (->
          retrievePaymentInfo paymentId
          return
        ), timeBetweenRetrievesMS
      else
        window.location = response.redirect_url

$(document).ready onLoad
