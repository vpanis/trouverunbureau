angular.module('deskSpotting.wishlist', []).controller "WishlistCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.spaces = []
    $scope.totalSpaces = 0
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.getSpaces = () ->
      show_spinner()
      Restangular.one('wishlist').get({page: $scope.currentPage, amount: $scope.itemsPerPage}).then (result) ->
        hide_spinner()
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        if $scope.totalSpaces > 0
          $(".wishlist-pagination").show()
        return
      return
    $scope.removeFavorite = (id, refresh_list, element) ->
      show_spinner()
      Restangular.one('wishlist', id).remove().then (result) ->
        hide_spinner()
        if refresh_list
          $scope.getSpaces()
        else
          $(element).removeClass('active')
          element.dataset.isFavorite = false
        return
      return
    $scope.addToFavorites = (id, element) ->
      show_spinner()
      Restangular.one('wishlist').customPOST({id: id}).then (result) ->
        hide_spinner()
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
