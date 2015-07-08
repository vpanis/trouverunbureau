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
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
    $translateProvider.translations 'de',
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
    $translateProvider.translations 'es',
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
    $translateProvider.translations 'fr',
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
    $translateProvider.translations 'it',
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
    $translateProvider.translations 'pt',
      'new': 'new'
      'pending_authorization': 'pending'
      'pending_payment': 'approved'
      'paid': 'paid'
      'cancelled': 'cancelled'
      'denied': 'denied'
      'expired': 'pending'
      'payment_verification': 'verifying'
      'refunding': 'refunding'
      'error_refunding': 'refunding'
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
