angular.module('deskSpotting.reviews', []).controller("ReviewsCtrl", ReviewsController = ($scope, Restangular) ->
  $scope.defaultAvatar = $('.reviews-list')[0].dataset.avatar

  getReviews = ->
    Restangular.one('venues', 1).getList('reviews').then (reviews) ->
      $scope.reviews = reviews

  getReviews()
)
