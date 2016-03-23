on_load = ->
  load
    controllers:
      payments: ["new"]
  , (controller, action) ->
    clean_credit_card_details = ->
    $('.new-credit-card').on 'click', (event) ->
      $("#required-label").addClass("hidden")
      $(".js-card-info :input").attr('disabled', false)
      $("#js-card_currency").val($("#js-card_currency option:first").val());
      $("#js-card_type").val($("#js-card_type option:first").val());
      $('#js-card_number').val("")
      $('#js-card_exp_date_month').val("")
      $('#js-card_exp_date_year').val("")
      $('#js-card_cvx').val("")
$(document).ready on_load
