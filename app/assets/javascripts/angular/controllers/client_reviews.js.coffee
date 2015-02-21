angular.module('deskSpotting.client_reviews', []).controller "ClientReviewsCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.defaultAvatar = $('.reviews-list')[0].dataset.avatar
    $scope.clientId = $('.reviews-list')[0].dataset.clientId
    $scope.reviews = []
    $scope.totalReviews = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 5
    $scope.getReviews = () ->
      Restangular.one('users', $scope.clientId).customGET('reviews', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        console.log(result)
        $scope.reviews = result.reviews
        $scope.totalReviews = result.count
        $scope.currentPage = result.current_page
        return
    $scope.getReviews()
]
