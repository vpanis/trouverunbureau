angular.module('deskSpotting.search', []).controller "SearchCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    $scope.spaces = []
    $scope.totalSpaces = ""
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.from = 1
    $scope.to = 12
    $scope.first_load = true
    $scope.on_change_time = 0
    $scope.filters = { Workspace: [], Profession: [], Capacity: null, Neighborhood: null, Date: null}
    $scope.countFilters = 0;
    parameters = document.getElementById('controller').dataset
    $scope.marker_icon = parameters.markerIcon
    $scope.markers = []
    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
      show_weeks: false
    $scope.format = 'dd-MM-yyyy'

    $scope.getSpaces = () ->

      search_parameters =
        page: $scope.currentPage
        amount: $scope.itemsPerPage
        latitude_to: $scope.latitude_to
        latitude_from: $scope.latitude_from
        longitude_to: $scope.longitude_to
        longitude_from: $scope.longitude_from
        capacity: $scope.filters.Capacity
        venue_professions: $scope.filters.Profession
        space_types: $scope.filters.Workspace
        date: $scope.filters.Date
      Restangular.one('spaces').get(search_parameters).then (result) ->
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        $scope.from = ($scope.itemsPerPage)*($scope.currentPage-1) + 1
        $scope.to = Math.min(($scope.itemsPerPage)*($scope.currentPage), $scope.totalSpaces)
        if $scope.totalSpaces > 0
          $(".search-pagination").show()
          if $scope.first_load
            initialize_map()
            $scope.first_load = false
          else
            update_map()
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

    $scope.getLatLong = ->
      address = $("#controller").attr('data-position-address')
      getLatLongFromAddress(address.replace(RegExp(' ', 'g'), '+'))
      return

    getLatLongFromAddress = (address) ->
      geocoder = new google.maps.Geocoder();
      geocoder.geocode { 'address': address }, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          ne = results[0].geometry.bounds.getNorthEast()
          sw = results[0].geometry.bounds.getSouthWest()
          $scope.latitude_from = if sw.lat() > 0 then ne.lat() else sw.lat()
          $scope.latitude_to = if sw.lat() > 0 then sw.lat() else ne.lat()
          $scope.longitude_from = if sw.lng() > 0 then ne.lng() else sw.lng()
          $scope.longitude_to = if sw.lng() > 0 then sw.lng() else ne.lng()
          $scope.getSpaces()
        else
          console.log('Geocode was not successful for the following reason: ' + status)
        return
      return

    initialize_map = ->

      mapOptions =
        center:
          lat: ($scope.latitude_from + $scope.latitude_from ) / 2
          lng: ($scope.longitude_from + $scope.longitude_from ) / 2
        zoom: 14
        scrollwheel: false

      $scope.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      i = 0
      bounds = new google.maps.LatLngBounds()
      while i < $scope.spaces.length
        space = $scope.spaces[i]
        space_position = new google.maps.LatLng(parseFloat(space.latitude), parseFloat(space.longitude))
        marker =
          position:
            lat: parseFloat(space.latitude)
            lng: parseFloat(space.longitude)
          icon:
            url: $scope.marker_icon
            scaledSize: new (google.maps.Size)(30, 40)
          map: $scope.map
        $scope.markers[i] = new (google.maps.Marker)(marker)
        bounds.extend(space_position)
        i++
      $scope.map.fitBounds(bounds)
      google.maps.event.addListener $scope.map, 'bounds_changed', ->
        $scope.on_change_time++
        if !$scope.first_load && $scope.on_change_time>3
          ne = $scope.map.getBounds().getNorthEast()
          sw = $scope.map.getBounds().getSouthWest()
          $scope.latitude_from = if sw.lat() > 0 then ne.lat() else sw.lat()
          $scope.latitude_to = if sw.lat() > 0 then sw.lat() else ne.lat()
          $scope.longitude_from = if sw.lng() > 0 then ne.lng() else sw.lng()
          $scope.longitude_to = if sw.lng() > 0 then sw.lng() else ne.lng()
          $scope.getSpaces()
        return
      return

    update_map = ->
      i = 0
      while i < $scope.markers.length
        $scope.markers[i].setMap(null)
        i++
      $scope.markers = []
      $scope.markers.length = 0

      i = 0
      while i < $scope.spaces.length
        space = $scope.spaces[i]
        space_position = new google.maps.LatLng(parseFloat(space.latitude), parseFloat(space.longitude))
        marker =
          position:
            lat: parseFloat(space.latitude)
            lng: parseFloat(space.longitude)
          icon:
            url: $scope.marker_icon
            scaledSize: new (google.maps.Size)(30, 40)
          map: $scope.map
        $scope.markers[i] = new (google.maps.Marker)(marker)
        i++

    $scope.showFilters = ->
      reset_filters()

      form_parameters = $('#filtersForm').serializeArray()
      i = 0
      while i < form_parameters.length
        param = form_parameters[i]
        if param.name == 'capacity'
          if $scope.filters.Capacity == null then $scope.countFilters++
          $scope.filters.Capacity = Math.min($scope.filters.capacity, parseInt(param.value))
        else if param.name == 'professions'
          if $scope.filters.Profession.length <= 0 then $scope.countFilters++
          $scope.filters.Profession.push(param.value)
        else if param.name == 'workspace'
          if $scope.filters.Workspace.length <= 0 then $scope.countFilters++
          $scope.filters.Workspace.push(param.value)
        else if param.name == 'neighborhood'
          if param.value != '' then $scope.countFilters++
          $scope.filters.Neighborhood = param.value
        else if param.name == 'check_in'
          if param.value != '' then $scope.countFilters++
          $scope.filters.Date = param.value
        i++


    $scope.removeFilter = (filter_name)->
      element = event.currentTarget
      if filter_name == 'Date' then filter_name = 'check_in'
      if $("input[id^='"+filter_name.toLowerCase()+"']").is('input[type="text"]')
        $("input[id^='"+filter_name.toLowerCase()+"']").val('')
      else
        $("input[id^='"+filter_name.toLowerCase()+"']").attr('checked',false)
      $scope.countFilters--
      element.remove()

    $scope.removeFilterAll = ->
      $('.colapse').remove()
      $('input[type="text"]').val('')
      $('input[type="checkbox"]').attr('checked', false)
      reset_filters()
      event.currentTarget.remove()

    reset_filters = ->
      $scope.filters = { Workspace: [], Profession: [], Capacity: null}
      $scope.countFilters = 0

    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return

    reset_filters()
    $scope.getLatLong()
]
