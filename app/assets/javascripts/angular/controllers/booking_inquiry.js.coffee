angular.module('deskSpotting.booking_inquiry', []).controller "BookingInquiryCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->

    # SCOPE FUNCTIONS

    $scope.updateMonthToMonth = () ->
      if (!$scope.booking_from)
        return

      booking_from = new Date($scope.booking_from)
      booking_from.setDate(booking_from.getDate() + per_month_to_month_as_of)

      dd = booking_from.getDate()
      mm = booking_from.getMonth() + 1
      yyyy = booking_from.getFullYear()

      if(dd < 10)
        dd = '0' + dd

      if(mm < 10)
        mm = '0' + mm

      $scope.month_to_month_as_of = dd+'-'+mm+'-'+yyyy;

    $scope.open = ($event, $input_open) ->
      $event.preventDefault()
      $event.stopPropagation()
      close_all()
      $scope[$input_open] = true

    $scope.initialize_dates = () ->
      $scope.booking_from = $('#booking_from').value
      $scope.booking_to = $('#booking_to').value

    $scope.swap_inquiry_type = (show_class, tab, tab_name) ->
      hide_forms()
      $(show_class).removeClass('form--hidden')
      $scope.selected_tab = tab
      $scope.selected_tab_name = tab_name

    $scope.disabled = (date, mode) ->
      days = [0, 1, 2, 3, 4, 5, 6]
      $.each available_dates_hours, () ->
        datepicker_weekday = ((@weekday + 1) % 7)
        _.pull(days, datepicker_weekday)
      return mode == 'day' && $.inArray(date.getDay(), days) >= 0

    $scope.hours_for_day = () ->
      if not $scope.booking_from?
        $('form .hour-select').prop('disabled', true);
        return
      available_hours = []
      $.each available_dates_hours, () ->
        datepicker_weekday = ((@weekday + 1) % 7)
        if datepicker_weekday == $scope.booking_from.getDay()
          current_hour = @from
          while current_hour <= @to
            hour = current_hour / 100
            hour = Math.floor(hour)
            mins = current_hour % 100
            addition_hours = if hour > 9 then "" else "0"
            addition_mins = if mins > 0 then "" else "0"
            current_hour_string = addition_hours + hour + ":" + mins + addition_mins
            available_hours.push(current_hour_string)
            if mins > 0
              # hours use 800 830 900 as its type, so we increment 70 to change from half an hour to
              # a full hour
              current_hour += 70
            else
              current_hour += 30
      if available_hours.length == 0
        $('form .hour-select').prop('disabled', true);
      else
        $('form .hour-select').prop('disabled', false);
        initialize_selects();
        $scope.hour_booking_begin = available_hours[0] unless $scope.hour_booking_begin?
        $scope.hour_booking_end = available_hours[(available_hours.length) - 1] unless $scope.hour_booking_end?
        $('#hour_booking_to').val($scope.hour_booking_end) unless $scope.hour_booking_end?
      return available_hours

    $scope.amount_for_booking_type = () ->
      if $scope.selected_tab == 'hour'
        return stablish_hours_amount()
      else if $scope.selected_tab == 'day'
        if not $scope.booking_from? or not $scope.booking_to?
          return 0
        return calculate_available_dates()
      else
        if not $scope.booking_from?
          $('#month_quantity').prop('disabled', true);
          return 0
        else
          $('#month_quantity').prop('disabled', false);
        return $scope.month_quantity

    $scope.booking_type_per_price = () ->
      if $scope.selected_tab == 'hour'
        return per_hour_price
      else if $scope.selected_tab == 'day'
        return per_day_price
      else if $scope.selected_tab == 'month'
        return per_month_price
      else
        return per_month_to_month_price

    $scope.month_to_month_minimum_quantity = () ->
      return per_month_to_month_minimum_quantity

    $scope.calculate_space_quantity = () ->
      return if $scope.space_quantity then $scope.space_quantity else 0

    $scope.calculate_deposit = () ->
      return $scope.space_deposit * $scope.calculate_space_quantity()

    $scope.calculate_space_booking = () ->
      res = $scope.booking_type_per_price() * $scope.amount_for_booking_type() * $scope.calculate_space_quantity()

      if $scope.selected_tab == 'month_to_month'
        res *= $scope.month_to_month_minimum_quantity()

      return res

    $scope.calculate_space_total = () ->
      return $scope.calculate_space_booking() + $scope.calculate_deposit()

    $scope.submit_form = () ->
      h = {}
      h['ID'] = $("#venue-id").attr('data-venue-id')
      h['Venue City'] = $("#venue-city").attr('data-venue-city')
      h['Venue Country'] = $("#venue-country").attr('data-venue-country')
      h['Booking Type'] = $scope.selected_tab_name
      mixpanel.track('Book Inquiry', h)

      if $scope.selected_tab == 'hour'
        $('#hour-form').find(':submit').click()
      else if $scope.selected_tab == 'day'
        $('#day-form').find(':submit').click()
      else if $scope.selected_tab == 'month'
        $('#month-form').find(':submit').click()
      else
        $('#month_to_month-form').find(':submit').click()
      return

    # PRIVATE FUNCTIONS

    deselect_all_tabs = () ->
      $scope.per_hour_selected = false
      $scope.per_day_selected = false
      $scope.per_month_selected = false
      $scope.per_month_to_month_selected = false

    stablish_hours_amount = () ->
      if !$scope.hour_booking_begin || !$scope.hour_booking_end
        return 0
      beginning_date_parts = $scope.hour_booking_begin.split(":")
      ending_date_parts = $scope.hour_booking_end.split(":")
      hour_diff = parseInt(ending_date_parts[0]) - parseInt(beginning_date_parts[0])
      min_diff = parseInt(ending_date_parts[1]) - parseInt(beginning_date_parts[1])
      if hour_diff < 1
        if min_diff <= 0
          return 0
        else
          return 1
      else
        if min_diff <= 0
          return hour_diff
        else
          return hour_diff + 1

    close_all = () ->
      $scope.opened_from = false
      $scope.opened_to = false
      $scope.hour_opened_date = false

    hide_forms = () ->
      $('.inquiring-container .form').addClass('form--hidden')

    calculate_available_dates = () ->
      current_date = new Date($scope.booking_from)
      end_date = $scope.booking_to
      counter = 0
      while current_date <= end_date
        $.each available_dates_hours, () ->
          datepicker_weekday =  ((@weekday + 1) % 7)
          if current_date.getDay() == datepicker_weekday
            counter++
        current_date.setDate(current_date.getDate() + 1)
      return counter

    # CONTROLLER CODE

    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
      show_weeks: false
    $scope.format = 'dd-MM-yyyy'
    $scope.initialize_dates()
    $scope.space_quantity = 1
    $scope.month_to_month_as_of = ""
    $scope.space_deposit = parseFloat($("#space-deposit").attr('data-amount'))
    close_all
    deselect_all_tabs();
    if $('.multiple-switch-wrapper .tab').attr('id') == 'tab-hour'
      $scope.selected_tab = 'hour'
    else if $('.multiple-switch-wrapper .tab').attr('id') == 'tab-day'
      $scope.selected_tab = 'day'
    else
      $scope.selected_tab = 'month'
    $($('.form-container .form')[0]).removeClass('form--hidden')

    available_dates_hours = $.parseJSON($("#venue-hours").attr('data-day-hours'))
    per_hour_price = $("#venue-hour-price").attr('data-hour-price')
    per_day_price = $("#venue-day-price").attr('data-day-price')
    per_month_price = $("#venue-month-price").attr('data-month-price')
    per_month_to_month_price = $("#venue-month_to_month-price").attr('data-month_to_month-price')
    per_month_to_month_minimum_quantity = $("#venue-month_to_month-minimum-quantity").attr('data-month_to_month-minimum-quantity')
    per_month_to_month_as_of = parseInt($("#venue-month_to_month-as-of").attr('data-month_to_month-as-of'))
    $scope.month_quantity = 1

    #initializers
    initialize_selects = ->
      $('#hour_booking_from').select2()
      $('#hour_booking_to').select2()
      return

    destroy_selects = ->
      $('#hour_booking_from').select2("destroy")
      $('#hour_booking_to').select2("destroy")
]

angular.module("deskSpotting.booking_inquiry").directive "datepickerPopup", (dateFilter, datepickerPopupConfig) ->
  restrict: "A"
  priority: 1
  require: "ngModel"
  link: (scope, element, attr, ngModel) ->
    dateFormat = attr.datepickerPopup or datepickerPopupConfig.datepickerPopup
    ngModel.$formatters.push (value) ->
      dateFilter value, dateFormat
