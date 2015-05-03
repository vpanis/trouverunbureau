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
      Restangular.one(entity, id).customGET('inquiries', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
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
      Restangular.one('inquiries', booking_id).one('last_seen_message').customPUT({message_id: message_id}).then (result) ->
        return

    reload_messages = () ->
      booking_id = $scope.selected_booking.id
      Restangular.one('inquiries', booking_id).customGET('messages').then (result) ->
        $scope.messages = result.messages
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
      Restangular.one('inquiries', $scope.selected_booking.id).one('messages').customPOST({message: {text: text}}).then (result) ->
        $scope.message_text = ''
        reload_messages()
        return
      return

    $scope.getCorrectDate = (booking, date) ->
      if booking.b_type != 'hour'
        date.split(" ")[0]
      else
        separateDate = date.split(" ")
        displayDate = separateDate[0].split("-")
        displayHour = separateDate[1].split(":")
        displayDate[2] + "-" + displayDate[1] + "-" + displayDate[0] + " " + displayHour[0] + ":" + displayHour[1]

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
      if $scope.selected_booking.client.id != parseInt($scope.user_id)
        Restangular.one('inquiries', $scope.selected_booking.id).one('deny').customPUT().then (result) ->
          $scope.selected_booking.state = 'denied'
          reload_messages()
          return
      else
        Restangular.one('inquiries', $scope.selected_booking.id).one('cancel').customPUT().then (result) ->
          $scope.selected_booking.state = 'canceled'
          reload_messages()
          return

    $scope.payBoooking = () ->
      console.log 'approved'

    $scope.approveBoooking = () ->
      Restangular.one('inquiries', $scope.selected_booking.id).one('accept').customPUT().then (result) ->
        $scope.selected_booking.state = 'pending_payment'
        reload_messages()
        return

    $scope.sendNewOffer = () ->
      if not $('#price-form')[0].checkValidity()
        $('#price-form')[0].submit()
      else
        price = $('#price-input')[0].value
        Restangular.one('inquiries', $scope.selected_booking.id).one('edit').customPUT({price: price}).then (result) ->
          reload_messages()
          $scope.selected_booking.price = parseInt(price)
          return

    $scope.getBookings()
]
