angular.module('deskSpotting.reviews', []).controller("ReviewsCtrl", ReviewsController = ($scope) ->
  stubAvatar = $('.marker_icon').html()
  getReviews = ->
    $scope.reviews = [
      {
        text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec iaculis purus ac felis. Phasellus id hendrerit ante. In hac habitasse platea dictumst"
        user:
          name: 'User name'
          avatar: stubAvatar
      },
      {
        text: "review2"
        user:
          name: 'user name2'
          avatar: stubAvatar
      },
      {
        text: "review3"
        user:
          name: 'user name 3'
          avatar: stubAvatar
      },
      {
        text: "review4"
        user:
          name: 'user name 4'

      }
    ]
  getReviews()
)
