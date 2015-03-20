angular.module('deskSpotting.booking_inquiry', []).controller "BookingInquiryCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.open = ($event, $input_open) ->
      $event.preventDefault()
      $event.stopPropagation()
      close_all()
      $scope[$input_open] = true

    close_all = () ->
      $scope.opened_from = false
      $scope.opened_to = false
      $scope.hour_opened_date = false

    hide_forms = () ->
      $('.inquiring-container .form').addClass('form--hidden')

    $scope.initialize_dates = () ->
      $scope.booking_from = $('#booking_from').value
      $scope.booking_to = $('#booking_to').value
      $scope.hour_booking_date = $('#hour_booking_date').value

    $scope.swap_inquiry_type = ($show_class) ->
      hide_forms()
      $($show_class).removeClass('form--hidden')

    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
      show_weeks: false
    $scope.format = 'dd-MM-yyyy'
    $scope.initialize_dates()
    close_all

    $('.multiple-switch-wrapper .tab:first-child').addClass('tab--selected')
    $('.form-container .form:first-child').removeClass('form--hidden')
]
