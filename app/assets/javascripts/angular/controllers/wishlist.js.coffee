angular.module('deskSpotting.wishlist', []).controller "WishlistCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.userId = $('.spaces-list')[0].dataset.userId
    $scope.spaces = []
    $scope.totalSpaces = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.getSpaces = () ->
      Restangular.one('users', $scope.userId).customGET('wishlist', {page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        if $scope.totalSpaces > 0
          $(".wishlist-pagination").show()
        return
      return

    $scope.getSpaces()
]
