timeBetweenRetrievesMS = 1000
selectedCreditCardId = null

onLoad = ->
  load
    controllers:
      payments: ["new", "create"]
  , ->
    mangopayConfiguration = $("#js-mangopay-config")[0].dataset
    mangoPay.cardRegistration.baseURL = mangopayConfiguration.baseUrl
    mangoPay.cardRegistration.clientId = mangopayConfiguration.clientId
    bookingPaymentData = $("#hidden-data")[0].dataset

    $('.js-create-card-registration').on 'click', (event) ->
      $("#new-credit-card").addClass("loading")
      createNewCardRegistration $('#js-card_currency').val().toUpperCase()

    $('.js-credit-card').on 'click', select_card

    $('#js-pay').on 'click', (event) ->
      if selectedCreditCardId != null
        mixpanel.track('Paid Booking', $("#hidden-data")[0].dataset)
        fbq('track', 'Purchase', {value: bookingPaymentData.bookingAmount, currency: bookingPaymentData.bookingCurrency});
        pay(selectedCreditCardId)

    # If the payment is in a expected response status
    if bookingPaymentData.bookingState == "payment_verification" and
      (bookingPaymentData.paymentState == 'EXPECTING_RESPONSE' or
        bookingPaymentData.paymentState == 'PAYING_CREATED')
      disableCardSelection()
      retrievePaymentInfo(bookingPaymentData.paymentId)

select_card = (event) ->
  selectedCreditCardId = this.dataset.creditCardId
  $('.js-credit-card').removeClass('active')
  $(this).addClass('active')
  $(this).find('input').prop("checked", true)
  $('.js-no-card-error').addClass('hidden')
  return

createNewCardRegistration = (currency) ->
  selectedCreditCardId = null
  $('.js-credit-card').removeClass('active')
  $('#register-credit-card').attr('disabled', 'disabled')
  show_spinner()
  $.ajax
    url: '/api/v1/mangopay/card_registration'
    method: 'POST'
    data:
      currency: currency
    success: (response) ->
      hide_spinner()
      setTimeout (->
        retrieveNewCardInfo response.mangopay_credit_card_id, currency
        return
      ), timeBetweenRetrievesMS

retrieveNewCardInfo = (creditCardId, currency) ->
  show_spinner()
  $.ajax
    url: '/api/v1/mangopay/new_card_info?mangopay_credit_card_id=' + creditCardId
    success: (response) ->
      hide_spinner()
      if response == null || ((typeof response == 'string' || response instanceof String) && response.trim() == '')
        setTimeout (->
          retrieveNewCardInfo creditCardId, currency
          return
        ), timeBetweenRetrievesMS
      else
        mangoPay.cardRegistration.init
          cardRegistrationURL: response.card_registration_url
          preregistrationData: response.pre_registration_data
          accessKey: response.registration_access_key
          Id: response.registration_id
        $('#register-credit-card').removeAttr('disabled')
        $("#new-credit-card").removeClass("loading")
        $('.js-create-credit-card').on 'click', (event) ->
          saveNewCard(creditCardId, currency)

saveNewCard = (creditCardId, currency) ->
  $(".js-card-errors").addClass("hidden")
  $("#required-label").addClass("hidden")
  nonEmptyVal = _.reduce $('.js-card-info input'), ((acc, input) ->
    acc and $(input).val()
  ), true
  nonEmptySelect = _.reduce $('.js-card-info select'), ((acc, select) ->
    acc and $(select).val()
  ), true

  if !nonEmptyVal || !nonEmptySelect
    $("#required-label").removeClass("hidden")
    return
  $("#new-credit-card").addClass("loading")
  cardData =
    cardNumber: $("#js-card_number").val()
    cardExpirationDate: $("#js-card_exp_date_month").val() + $("#js-card_exp_date_year").val()
    cardCvx: $("#js-card_cvx").val()
    cardType: $("#js-card_type").val()

  $('.js-create-credit-card').attr('disabled', 'disabled')
  $(".js-card-info :input").attr('disabled', true)
  mangoPay.cardRegistration.registerCard cardData, ((response) ->
    expiration = $("#js-card_exp_date_month").val() + '/' + $("#js-card_exp_date_year").val()
    # Success, you can use res.CardId now that points to registered card
    show_spinner()
    $.ajax
      url: '/api/v1/mangopay/save_credit_card'
      method: 'PUT'
      data:
        mangopay_credit_card:
          id: creditCardId
          credit_card_id: response.CardId
          last_4: cardData.cardNumber.substring(cardData.cardNumber.length - 4)
          expiration: expiration
          card_type: cardData.cardType
      success: (response) ->
        hide_spinner()
        $('.js-create-credit-card').removeAttr('disabled')
        $(".js-card-info :input").attr('disabled', false)
        $("#new-credit-card").removeClass("loading")
        $("#js-create-credit-card").remove()
        selectedCreditCardId = creditCardId
        $('.js-credit-cards').append(creditCardTemplate(creditCardId, cardData.cardNumber.substring(cardData.cardNumber.length - 4), expiration, currency))
        $('.js-credit-card').last().on 'click', select_card
        $('#create-credit-card').modal('hide')
        return
      error: (response) ->
        hide_spinner()
        $('.js-create-credit-card').removeAttr('disabled')
        $(".js-card-info :input").attr('disabled', false)
        $("#new-credit-card").removeClass("loading")
        console.log(response)

    return
  ), (response) ->
    $("#new-credit-card").removeClass("loading")
    switch response.ResultCode
      when "105202"
        $(".js-card-format").removeClass("hidden")
      when "105203"
        $(".js-expiration-format").removeClass("hidden")
      when "105204"
        $(".js-cvx-format").removeClass("hidden")
    $('.js-create-credit-card').removeAttr('disabled')
    $(".js-card-info :input").attr('disabled', false)

    # Handle error, see res.ResultCode and res.ResultMessage
    return

creditCardTemplate = (creditCardId, creditCardLast4, expiration, currency) ->
  '<div class="js-credit-card" data-credit-card-id="' + creditCardId + '"><div class="credit-card col-md-4"><div class="radio-container"><input name="credit_card" type="radio"></div><div class="credit-card-info"><p><span>Last four digits: </span>' + creditCardLast4 + '</p><p><span>Type: </span>CB/VISA/MASTERCARD</p><p><span>Expiration date: </span>' + expiration + '</p><p><span>Currency: </span>' + currency + '</p></div></div></div>'

disableCardSelection = ->
  $("#js-pay").attr('disabled', true)
  $('.js-credit-card').attr('disabled', true)

pay = (card_id) ->
  disableCardSelection()
  bookingId = $("#hidden-data")[0].dataset.bookingId
  if selectedCreditCardId == null
    $('.js-no-card-error').removeClass('hidden')
    return
  show_spinner()
  $.ajax
    url: '/api/v1/mangopay/start_payment'
    method: 'PUT'
    data:
      booking_id: bookingId
      card_id: selectedCreditCardId
    success: (response) ->
      hide_spinner()
      setTimeout (->
        retrievePaymentInfo response.mangopay_payment.id
        return
      ), timeBetweenRetrievesMS

retrievePaymentInfo = (paymentId) ->
  show_spinner()
  $.ajax
    url: '/api/v1/mangopay/payment_info?payment_id=' + paymentId
    success: (response) ->
      hide_spinner()
      if response == null || ((typeof response == 'string' || response instanceof String) && response.trim() == '')
        setTimeout (->
          retrievePaymentInfo paymentId
          return
        ), timeBetweenRetrievesMS
      else
        window.location = response.redirect_url

$(document).ready onLoad
