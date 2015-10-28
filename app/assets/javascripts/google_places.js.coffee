on_load = ->
  element = $('#search')[0]
  if $('body')[0].dataset.controller == 'landing' || $('body')[0].dataset.action == 'search_mobile'
    element = $('.input-search-landing')[0]
  if google?
    southwest = new google.maps.LatLng(35.671389, -10.429529);
    northeast = new google.maps.LatLng(71.297598, 33.737111);
    b = new google.maps.LatLngBounds(southwest, northeast);
    autocomplete = new google.maps.places.Autocomplete(element, { types: ['geocode'], bounds: b })
    google.maps.event.addListener autocomplete, 'place_changed', ->
      geometry = autocomplete.getPlace().geometry
      if geometry
        $('#search').val(autocomplete.getPlace().formatted_address)
        if $('#menu-search-form').hasClass('js-menu-bar-search')
          $('#menu-search-form').submit()

$(document).ready on_load


