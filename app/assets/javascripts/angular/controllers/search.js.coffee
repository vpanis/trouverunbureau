angular.module('deskSpotting.search', []).controller "SearchCtrl", [
  '$scope'
  'Restangular'
  ($scope, Restangular) ->
    MAX_MOBILE_PIXELS_WIDE = 991
    $scope.spaces = []
    $scope.totalSpaces = ""
    $scope.currentPage = 1
    $scope.itemsPerPage = 12
    $scope.from = 1
    $scope.to = 12
    $scope.first_load = true
    $scope.load_count = 0
    $scope.latitude_from = -90
    $scope.latitude_to = 90
    $scope.longitude_from = -180
    $scope.longitude_to = 180
    $scope.workspaces = []
    $scope.professions = {}
    $scope.capacity = null
    $scope.filters = []
    $scope.marker_icon = document.getElementById('controller').dataset.markerIcon
    $scope.active_icon = document.getElementById('controller').dataset.activeMarkerIcon
    $scope.markers = []
    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
      show_weeks: false
    $scope.format = 'dd-MM-yyyy'

    $scope.getSpaces = () ->
      Restangular.one('spaces').get(build_search_params()).then (result) ->
        $scope.spaces = result.spaces
        $scope.totalSpaces = result.count
        $scope.currentPage = result.current_page
        if $scope.totalSpaces == 0
          $scope.from = 0
          $scope.to = 0
        else
          $scope.from = ($scope.itemsPerPage)*($scope.currentPage-1) + 1
          $scope.to = Math.min(($scope.itemsPerPage)*($scope.currentPage), $scope.totalSpaces)
        $(".search-pagination").hide()
        if $scope.totalSpaces > 0
          $(".search-pagination").show()
        if !is_mobile()
          update_map($scope.first_load && $scope.load_count > 2)
          google.maps.event.addListenerOnce $scope.map, 'bounds_changed', ->
            bounds_changed_handler()
        $scope.load_count = $scope.load_count + 1
        if $scope.first_load
          $scope.first_load = false
      return

    is_mobile = ->
      return window.innerWidth < MAX_MOBILE_PIXELS_WIDE

    build_search_params = ->
      search_parameters =
        page: $scope.currentPage
        amount: $scope.itemsPerPage
        latitude_to: $scope.latitude_to
        latitude_from: $scope.latitude_from
        longitude_to: $scope.longitude_to
        longitude_from: $scope.longitude_from

      if $scope.check_in != undefined && $scope.check_in != null && $scope.check_in != ''
        search_parameters['date'] = $scope.check_in
      if $scope.capacity == '1'
        search_parameters['capacity_max'] = 1
      else if $scope.capacity == '2'
        search_parameters['capacity_min'] = 2

      search_parameters['space_types[]'] = build_workspace_types()
      search_parameters['venue_professions[]'] = build_professions()
      return search_parameters

    build_workspace_types = () ->
      types = []
      i = 0
      while i < $scope.workspaces.length
        if $scope.workspaces[i]
          types.push(i)
        i++
      return types

    build_professions = () ->
      professions = []
      for k of $scope.professions
        if $scope.professions[k]
          professions.push(k)
      return professions

    getUrlVars = ->
      vars = []
      hash = undefined
      hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
      i = 0
      while i < hashes.length
        hash = hashes[i].split('=')
        vars.push hash[0]
        vars[hash[0]] = hash[1]
        i++
      vars

    $scope.getSpaceType = ->
      type = getUrlVars()['s_type']
      if type && type % 1 == 0
        $scope.workspaces[type] = true
        $scope.filters.push('workspaces')
      return

    $scope.getLatLong = ->
      address = getUrlVars()['search']
      if address
        return getLatLongFromAddress(address.replace(RegExp(' ', 'g'), '+').replace(RegExp('%2C', 'g'), '+'))
      $scope.getSpaces()
      return

    $scope.leaveSpace = (space) ->
      $scope.selectedMarker.setMap(null)

    $scope.selectSpace = (space) ->
      marker = build_marker(space)
      marker.icon.url = $scope.active_icon
      $scope.selectedMarker = new (google.maps.Marker)(marker)

    calculate_bounds = (results) ->
      if results[0].geometry.bounds
        ne = results[0].geometry.bounds.getNorthEast()
        sw = results[0].geometry.bounds.getSouthWest()
      else
        ne = results[0].geometry.location
        sw = results[0].geometry.location
      setBoundsToScope(ne, sw)

    setBoundsToScope = (ne, sw) ->
      $scope.latitude_from = sw.lat()
      $scope.latitude_to = ne.lat()
      $scope.longitude_from = sw.lng()
      $scope.longitude_to = ne.lng()
      return

    getLatLongFromAddress = (address) ->
      geocoder = new google.maps.Geocoder();
      geocoder.geocode { 'address': address }, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          calculate_bounds(results)
        else
          console.log('Geocode was not successful for the following reason: ' + status)
        initialize_map()
        $scope.getSpaces()
        return
      return

    calc_initial_bounds = () ->
      from = new google.maps.LatLng(parseFloat($scope.latitude_from), parseFloat($scope.longitude_from))
      to =  new google.maps.LatLng(parseFloat($scope.latitude_to), parseFloat($scope.longitude_to))
      return new google.maps.LatLngBounds(from, to)

    initialize_map = ->
      if is_mobile()
        return
      bounds = calc_initial_bounds()
      mapOptions =
        center: bounds.getCenter()
        scrollwheel: false
        streetViewControl: false
        zoomControl: true
        zoomControlOptions:
          style: google.maps.ZoomControlStyle.DEFAULT
          position: google.maps.ControlPosition.RIGHT_TOP
      $scope.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
      $scope.map.fitBounds(bounds)

    bounds_changed_handler = ->
      ne = $scope.map.getBounds().getNorthEast()
      sw = $scope.map.getBounds().getSouthWest()
      setBoundsToScope(ne, sw)
      $scope.getSpaces()
      return

    build_marker = (space) ->
      marker =
        position:
          lat: parseFloat(space.latitude)
          lng: parseFloat(space.longitude)
        icon:
          url: $scope.marker_icon
          scaledSize: new (google.maps.Size)(30, 40)
        map: $scope.map
      return marker

    add_marker_to_map = (i) ->
      space = $scope.spaces[i]
      space_position = new google.maps.LatLng(parseFloat(space.latitude), parseFloat(space.longitude))
      marker = build_marker(space)
      $scope.markers[i] = new (google.maps.Marker)(marker)
      google.maps.event.addListener $scope.markers[i], 'mouseover', ->
        $scope.markers[i].setIcon $scope.active_icon
      google.maps.event.addListener $scope.markers[i], 'mouseout', ->
        $scope.markers[i].setIcon $scope.marker_icon
      return space_position

    remove_markers = ->
      i = 0
      while i < $scope.markers.length
        $scope.markers[i].setMap(null)
        i++
      $scope.markers = []

    add_markers = (fitbounds)->
      i = 0
      bounds = new google.maps.LatLngBounds();
      while i < $scope.spaces.length
        space_position = add_marker_to_map(i)
        if !(bounds.contains(space_position))
          bounds.extend(space_position)
        i++
      if ($scope.spaces.length > 0 && fitbounds)
        $scope.map.fitBounds(bounds)
      return

    update_map = (fitbounds)->
      remove_markers()
      add_markers(fitbounds)
      return

    $scope.showFilters = ->
      $scope.filters = []
      if $scope.workspaces.length > 0
        $scope.filters.push('workspaces')
      if ! $.isEmptyObject($scope.professions)
        $scope.filters.push('professions')
      if $scope.capacity != null
        $scope.filters.push('capacity')
      if $scope.check_in != undefined && $scope.check_in != null && $scope.check_in != ''
        $scope.filters.push('check in')
      $scope.getSpaces()
      return

    $scope.removeFilter = (filter_name)->
      if filter_name == 'workspaces'
        $scope.workspaces = []
      if filter_name == 'professions'
        $scope.professions = {}
      if filter_name == 'capacity'
        $scope.capacity = null
      if filter_name == 'check in'
        $scope.check_in = ''
      $scope.showFilters()
      return

    $scope.removeFilterAll = ->
      $('.colapse').remove()
      $scope.workspaces = []
      $scope.professions = {}
      $scope.capacity = null
      $scope.filters = []
      $scope.getSpaces()
      event.currentTarget.remove()
      return

    $scope.openCalendar = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
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

    $scope.getSpaceType()
    $scope.getLatLong()
]
