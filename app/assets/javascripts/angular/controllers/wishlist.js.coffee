angular.module('deskSpotting.wishlist', []).controller "WishlistCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.spaces = []
    $scope.totalSpaces = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.getSpaces = () ->
      Restangular.one('wishlist').get({page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        if $scope.totalSpaces > 0
          $(".wishlist-pagination").show()
        return
      return
    $scope.removeFavorite = (id) ->
      Restangular.one('wishlist', id).remove (result) ->
        $scope.getSpaces()
        return
      return
    $scope.getSpaces()
]
