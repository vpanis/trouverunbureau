# Defining the angular application
@deskspotting = angular.module('deskSpotting', [
  'restangular',
  'ui.bootstrap',
  'deskSpotting.reviews'
]).config (RestangularProvider) ->
  RestangularProvider.setBaseUrl 'http://private-82df-deskspotting.apiary-mock.com'
  return

#fix for ui.bootrstrap carousel
angular.module('ui.bootstrap.carousel', [ 'ui.bootstrap.transition' ]).controller('CarouselController', [
  '$scope'
  '$timeout'
  '$transition'
  '$q'
  ($scope, $timeout, $transition, $q) ->
]).directive 'carousel', [ ->
  {}
]
