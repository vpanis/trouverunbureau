angular.module('deskSpotting.organization_edit', []).controller "OrganizationEditCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.future_members = []

    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return

    $scope.addManager = ()->
      email = $('#email_field').val()
      role = $('#role_select').val()
      Restangular.one('users/info').get(email: email).then (result) ->
        $scope.future_members.push(result.user)
      return

      return

    return
]
