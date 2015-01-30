on_load = ->
  set_info_tab()
  initialize_map()

  $('#venue-info-selector').click ->
    set_info_tab()
  $('#venue-workspaces-selector').click ->
    set_workspace_tab()

set_workspace_tab = ->
  $('#venue-info-tab').hide()
  $('#venue-workspaces-tab').show()
  $('#venue-info-selector').removeClass('active')
  $('#venue-workspaces-selector').addClass('active')
  msnry = new Masonry(".cards-columns",
    itemSelector: ".space-card"
    gutter: 20
    isFitWidth: true
  )
set_info_tab = ->
  $('#venue-info-tab').show()
  $('#venue-workspaces-tab').hide()
  $('#venue-info-selector').addClass('active')
  $('#venue-workspaces-selector').removeClass('active')
  msnry = new Masonry(".info-columns",
    itemSelector: ".info-card"
    gutter: 20
    isFitWidth: true
  )
initialize_map = ->
  latitude = parseFloat($('.latitude').html())
  longitude = parseFloat($('.longitude').html())
  marker_icon = $('.marker_icon').html()

  mapOptions =
    center:
      lat: latitude
      lng: longitude
    zoom: 14
    scrollwheel: false
  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  marker =
    position:
      lat: latitude
      lng: longitude
    icon:
      url: marker_icon
      scaledSize: new google.maps.Size(20, 22)
    map: map
  new google.maps.Marker(marker);
  return

$(document).ready on_load
