angular.module('deskSpotting.inbox', []).controller "InboxCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.bookings = []
    $scope.totalBookings = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.selected_booking = {}
    $scope.messages = []
    $scope.message_text = ''
    $scope.user_id = $('.inbox')[0].dataset.userId
    $scope.organization_id = $('.inbox')[0].dataset.organizationId
    $scope.defaultAvatar = $('.inbox')[0].dataset.avatar
    $scope.defaultLogo = $('.inbox')[0].dataset.logo
    $scope.getBookings = () ->
      if $scope.organization_id
        getRemoteBookings('organizations', $scope.organization_id)
      else
        getRemoteBookings('users', $scope.user_id)

    getRemoteBookings = (entity, id) ->
      show_spinner()
      Restangular.one(entity, id).customGET('inquiries', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        hide_spinner()
        $scope.bookings = result.inquiries
        $scope.totalBookings = result.count
        $scope.currentPage = result.current_page
        if $scope.totalBookings > 0
          $scope.selectBooking($scope.bookings[0])
          $(".bookings-pagination").show()
      return

    $scope.selectBooking = (booking) ->
      $scope.selected_booking = booking
      $('#price-input')[0].value = $scope.selected_booking.price
      reload_messages()
      return

    mark_booking_as_read = (booking_id, message_id) ->
      show_spinner()
      Restangular.one('inquiries', booking_id).one('last_seen_message').customPUT({message_id: message_id}).then (result) ->
        hide_spinner()
        return

    reload_messages = () ->
      booking_id = $scope.selected_booking.id
      show_spinner()
      Restangular.one('inquiries', booking_id).customGET('messages').then (result) ->
        hide_spinner()
        $scope.messages = result.messages
        initialize_popovers()
        if $scope.messages.length > 0
          mark_booking_as_read(booking_id, $scope.messages[0].id)
          scroll_to_last_message()

    scroll_to_last_message = ->
      $('.messages-wrapper').stop().animate({scrollTop: 10000}, 800);

    $scope.sendMessage = () ->
      text = this.message_text
      if text == ''
        console.log('empty messages are ignored')
        return
      this.message_text = ''
      show_spinner()
      Restangular.one('inquiries', $scope.selected_booking.id).one('messages').customPOST({message: {text: text}}).then (result) ->
        hide_spinner()
        $scope.message_text = ''
        reload_messages()
        return
      return

    $scope.getDateDays = (date) ->
      date.split(" ")[0]

    $scope.getDateDaysFormatted = (date) ->
      a = date.split(" ")[0];
      b = a.split("-");
      b[2] + "-" + b[1] + "-" + b[0]

    $scope.getCorrectDate = (booking, date) ->
      if booking.b_type != 'hour'
        $scope.getDateDaysFormatted(date)
      else
        displayHour = date.split(" ")[1].split(":")
        displayHour[0] + ":" + displayHour[1]

    $scope.daysInBooking = (booking) ->
      _MS_PER_DAY = 1000 * 60 * 60 * 24;
      return Math.ceil((Date.parse(booking.to) - Date.parse(booking.from)) / _MS_PER_DAY);

    $scope.monthsInBooking = (booking) ->
      _MS_PER_MONTH = 1000 * 60 * 60 * 24 * 30;
      return Math.ceil((Date.parse(booking.to) - Date.parse(booking.from)) / _MS_PER_MONTH);

    $scope.showDecline = (booking) ->
      if booking.state == 'pending_authorization' or booking.state == 'pending_payment' or booking.state == 'paid' or booking.state == 'expired'
        return true
      return false
    $scope.showBookIt = (booking) ->
      if booking.state == 'pending_payment' and booking.client.id == parseInt($scope.user_id)
        return true
      return false
    $scope.showApprove = (booking) ->
      if (booking.state == 'pending_authorization' or booking.state == 'expired') and booking.client.id != parseInt($scope.user_id)
        return true
      return false
    $scope.showNewOffer = (booking) ->
      if (booking.state == 'pending_authorization' or booking.state == 'expired')  and booking.client.id != parseInt($scope.user_id)
        return true
      return false

    $scope.showGuest = (booking) ->
      return booking.client.id != parseInt($scope.user_id)

    $scope.declineBoooking = () ->
      show_spinner()
      if $scope.selected_booking.client.id != parseInt($scope.user_id)
        Restangular.one('inquiries', $scope.selected_booking.id).one('deny').customPUT().then (result) ->
          hide_spinner()
          $scope.selected_booking.state = 'denied'
          reload_messages()
          return
      else
        Restangular.one('inquiries', $scope.selected_booking.id).one('cancel').customPUT().then (result) ->
          hide_spinner()
          $scope.selected_booking.state = 'cancelled'
          reload_messages()
          return

    $scope.payBoooking = (selected_booking) ->
      window.location = "/payments/new?booking_id=" + selected_booking.id

    $scope.approveBoooking = () ->
      show_spinner()
      Restangular.one('inquiries', $scope.selected_booking.id).one('accept').customPUT().then (result) ->
        hide_spinner()
        $scope.selected_booking.state = 'pending_payment'
        reload_messages()
        return

    $scope.sendNewOffer = () ->
      if not $('#price-form')[0].checkValidity()
        $('#price-form')[0].submit()
      else
        price = $('#price-input')[0].value
        show_spinner()
        Restangular.one('inquiries', $scope.selected_booking.id).one('edit').customPUT({price: price}).then (result) ->
          hide_spinner()
          reload_messages()
          $scope.selected_booking.price = parseInt(price)
          return

    initialize_popovers = ->
      options = {
        placement: (context, source) ->
          position = $(source).offset()
          if (position.left > 160)
              return "left"
          if (position.left < 160)
              return "right"
          if (position.top < 110)
              return "bottom"
          return "top"
      }
      $('#space-rental-popover').popover(options)
      $('#deposit-popover').popover(options)
      $('#fee-popover').popover(options)
      $('#client-space-rental-popover').popover(options)
      $('#client-deposit-popover').popover(options)

    $scope.getBookings()
]
