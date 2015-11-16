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
      'workspaces': 'workspaces'
      'professions': 'professions'
      'capacity': 'number of people'
    $translateProvider.translations 'de',
      'new': 'Neu'
      'pending_authorization': 'Ausstehend'
      'pending_payment': 'Bestätigt'
      'paid': 'Bezahlt'
      'cancelled': 'Storniert'
      'denied': 'Abgelehnt'
      'expired': 'Abgelaufen'
      'payment_verification': 'Überprüfung'
      'refunding': 'Rückzahlung'
      'error_refunding': 'Fehler Rückzahlung'
      'workspaces': 'arbeitsplatz'
      'professions': 'beruf/tätigkeitsbereich'
      'capacity': 'personenanzahl'
    $translateProvider.translations 'es',
      'new': 'Nueva'
      'pending_authorization': 'Pendiente'
      'pending_payment': 'Aprobada'
      'paid': 'Pagada'
      'cancelled': 'Cancelada'
      'denied': 'Rechazada'
      'expired': 'Expirada'
      'payment_verification': 'Verificando'
      'refunding': 'Reembolsando'
      'error_refunding': 'Error de devolución'
      'workspaces': 'espacios de trabajo'
      'professions': 'profesión'
      'capacity': 'número de personas'
    $translateProvider.translations 'fr',
      'new': 'nouveau'
      'pending_authorization': 'en attente'
      'pending_payment': 'approuvé'
      'paid': 'payé'
      'cancelled': 'annulé'
      'denied': 'refusé'
      'expired': 'expiré'
      'payment_verification': 'verification'
      'refunding': 'remboursement'
      'error_refunding': 'erreur Remboursement'
      'workspaces': 'postes de Travail'
      'professions': 'profession'
      'capacity': 'nombre de personnes'
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
      'workspaces': 'workspaces'
      'professions': 'professions'
      'capacity': 'number of people'
    $translateProvider.translations 'pt',
      'new': 'Nova'
      'pending_authorization': 'Pendente'
      'pending_payment': 'Aprovado'
      'paid': 'Pago'
      'cancelled': 'Cancelado'
      'denied': 'Recusado'
      'expired': 'Expirado'
      'payment_verification': 'Em Verificação'
      'refunding': 'Reembolso em Curso'
      'error_refunding': 'Erro de Reembolso'
      'workspaces': 'postos de trabalho'
      'professions': 'profissão'
      'capacity': 'número de pessoas'
    $translateProvider.preferredLanguage $("body").attr("language")
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
