angular.module('deskSpotting.reviews', []).controller("ReviewsCtrl", ReviewsController = ($scope, Restangular) ->
  $scope.defaultAvatar = $('.reviews-list')[0].dataset.avatar
  $scope.venueId = $('.reviews-list')[0].dataset.venueId
  $scope.reviews = []
  $scope.totalReviews = 0
  $scope.currentPage = 1
  $scope.itemsPerPage = 5
  $scope.getReviews = () ->
    Restangular.one('venues', $scope.venueId).customGET('reviews', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
      $scope.reviews = result.reviews
      $scope.totalReviews = result.count
      $scope.currentPage = result.current_page

  $scope.getReviews()
)
