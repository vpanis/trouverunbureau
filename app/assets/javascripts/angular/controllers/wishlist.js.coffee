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
    $scope.removeFavorite = (id, refresh_list, element) ->
      Restangular.one('wishlist', id).remove().then (result) ->
        if refresh_list
          $scope.getSpaces()
        else
          $(element).removeClass('active')
          element.dataset.isFavorite = false
        return
      return
    $scope.addToFavorites = (id, element) ->
      Restangular.one('wishlist').customPOST({id: id}).then (result) ->
        $(element).addClass('active')
        element.dataset.isFavorite = true
        return
      return
    $scope.toggleFavorite = (id, refresh_list) ->
      element = event.currentTarget
      is_favorite = element.dataset.isFavorite
      if is_favorite == "true"
        return $scope.removeFavorite(id, refresh_list, element)
      return $scope.addToFavorites(id, element)
    $scope.getSpaces()
]
