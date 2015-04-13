angular.module('deskSpotting.organization_edit', []).controller "OrganizationEditCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.members = {}

    Restangular.one('organizations', $scope.organization_id).getList('organization_users').then (members) ->
      console.log members
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
      Restangular.one('organizations', $scope.organization_id).all('organization_users').post(newManager).then ((member) ->
        debugger
        $scope.members[member.id] = member
      ), ->
        console.log 'the user does not exist' # TODO: Sent email

    $scope.deleteMember = (member) ->
      Restangular.one('organizations', $scope.organization_id).one('organization_users', member.id).remove().then (result) ->
        delete $scope.members[member.id]

]
