angular.module('deskSpotting.user_profile', []).controller "UserProfileCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return
    $scope.initialize_dates = ()->
      $scope.user_date_of_birth = $('#user_date_of_birth')[0].value
      return
    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
      show_weeks: false
    $scope.format = 'dd-MM-yyyy'
    $scope.initialize_dates()
    return
]
