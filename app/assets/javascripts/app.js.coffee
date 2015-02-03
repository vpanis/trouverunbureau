# Defining the angular application
@deskspotting = angular.module('deskSpotting', [
  'deskSpotting.reviews',
  'restangular'
]).config ( RestangularProvider) ->
  RestangularProvider.setBaseUrl 'http://private-82df-deskspotting.apiary-mock.com'
  return
