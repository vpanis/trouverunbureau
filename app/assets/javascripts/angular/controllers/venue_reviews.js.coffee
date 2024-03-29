angular.module('deskSpotting.venue_reviews', []).controller "VenueReviewsCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.defaultAvatar = $('.reviews-list')[0].dataset.avatar
    $scope.venueId = $('.reviews-list')[0].dataset.venueId
    $scope.reviews = []
    $scope.totalReviews = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 5
    $scope.getReviews = () ->
      show_spinner()
      Restangular.one('venues', $scope.venueId).customGET('reviews', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        hide_spinner()
        $scope.reviews = result.reviews
        $scope.totalReviews = result.count
        $scope.currentPage = result.current_page
        if $scope.totalReviews > 0
          $(".venue-reviews-pagination").show()
        return
      return

    $scope.getReviews()
]
