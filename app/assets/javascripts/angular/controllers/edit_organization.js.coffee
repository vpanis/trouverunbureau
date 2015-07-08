angular.module('deskSpotting.organization_edit', []).controller "OrganizationEditCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.members = {}

    show_spinner()
    Restangular.one('organizations', $scope.organization_id).getList('organization_users').then (members) ->
      hide_spinner()
      angular.forEach members, (member, key) ->
        $scope.members[member.id] = member

    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true

    $scope.addManager = ->
      newManager = {
        role: $scope.role,
        email: $scope.email
      }
      show_spinner()
      Restangular.one('organizations', $scope.organization_id).all('organization_users').post(newManager).then ((member) ->
        hide_spinner()
        $scope.members[member.id] = member
      ), ->
        hide_spinner()
        console.log 'the user does not exist' # TODO: Sent email

    $scope.deleteMember = (member) ->
      show_spinner()
      Restangular.one('organizations', $scope.organization_id).one('organization_users', member.id).remove().then (result) ->
        hide_spinner()
        delete $scope.members[member.id]
        window.location.href = result.redirect_url if result && result.redirect_url

]
