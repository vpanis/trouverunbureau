angular.module('deskSpotting.home', ['ngCookies']).controller "HomeCtrl", [
  '$scope'
  '$cookies'
  ($scope, $cookies) ->
    clearFilters = ()->
      $cookies.remove('search_capacity')
      $cookies.remove('search_check_in')
      $cookies.remove('search_filters')
      $cookies.remove('search_professions')
      $cookies.remove('search_workspaces')

    clearFilters()
]
