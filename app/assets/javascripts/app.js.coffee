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
  'deskSpotting.user_profile',
  'deskSpotting.organization_edit',
  'pascalprecht.translate'
]).config (RestangularProvider) ->
  RestangularProvider.setBaseUrl '/api/v1'
  return

@deskspotting.config [
  '$translateProvider'
  ($translateProvider) ->
    $translateProvider.translations 'en',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.translations 'de',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.translations 'es',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.translations 'fr',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.translations 'it',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.translations 'pt',
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
    $translateProvider.preferredLanguage 'en'
    return
]

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
