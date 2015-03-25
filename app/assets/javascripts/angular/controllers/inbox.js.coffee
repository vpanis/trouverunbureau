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
    $scope.defaultAvatar = $('.inbox')[0].dataset.avatar
    $scope.defaultLogo = $('.inbox')[0].dataset.logo
    $scope.getBookings = () ->
      Restangular.one('users', $scope.user_id).customGET('inquiries', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        $scope.bookings = result.inquiries
        $scope.totalBookings = result.count
        $scope.currentPage = result.current_page
        if $scope.totalBookings > 0
          $scope.selected_booking = $scope.bookings[0]
          reload_messages()
          $(".bookings-pagination").show()
      return

    $scope.selectBooking = (booking) ->
      $scope.selected_booking = booking
      reload_messages()
      return

    reload_messages = () ->
      Restangular.one('inquiries', $scope.selected_booking.id).customGET('messages').then (result) ->
        $scope.messages = result.messages

    $scope.sendMessage = () ->
      text = $scope.message_text
      Restangular.one('inquiries', $scope.selected_booking.id).one('messages').customPOST({message: {text: text}}).then (result) ->
        $scope.message_text = ''
        reload_messages()
        return
      return

    $scope.getBookings()
]
