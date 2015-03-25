# Defining the angular application
@deskspotting = angular.module('deskSpotting', [
  'restangular',
  'ui.bootstrap',
  'deskSpotting.inbox',
  'deskSpotting.venue_reviews',
  'deskSpotting.client_reviews',
  'deskSpotting.wishlist',
  'deskSpotting.booking_inquiry'
  'deskSpotting.search',
  'deskSpotting.user_profile'
]).config (RestangularProvider) ->
  RestangularProvider.setBaseUrl '/api/v1'
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

@deskspotting.filter 'reverse', ->
  (items) ->
    items.slice().reverse()
