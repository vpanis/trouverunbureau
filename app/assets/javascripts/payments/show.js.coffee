on_load = ->
  load
    controllers:
      payments: ["show"]
  , (controller, action) ->
    $('.credit-cards-select').select2()
    $('.credit-cards-type-select').select2()
    $('#register-credit-card').click ->
      $('#new-credit-card').modal 'hide'
      $('#create-credit-card').modal 'show'
$(document).ready on_load
