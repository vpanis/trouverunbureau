angular.module('deskSpotting.organization_edit', []).controller "OrganizationEditCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return

    $scope.addManager = ()->
      email = $('#email_field').val()
      role = $('#role_select').val()
      Restangular.one('users/info').get(email: email).then (result) ->
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        $scope.from = ($scope.itemsPerPage)*($scope.currentPage-1) + 1
        $scope.to = Math.min(($scope.itemsPerPage)*($scope.currentPage), $scope.totalSpaces)
        if $scope.totalSpaces > 0
          $(".search-pagination").show()
        return
      return

      return

    return
]
