on_load = ->
  element = $('#search')[0]
  if $('body')[0].dataset.controller == 'landing' || $('body')[0].dataset.action == 'search_mobile'
    element = $('.input-search-landing')[0]

  autocomplete = new google.maps.places.Autocomplete(element, { types: ['geocode'] })
  google.maps.event.addListener autocomplete, 'place_changed', ->
    geometry = autocomplete.getPlace().geometry
    if geometry
      $('#menu-search-form').submit()

$(document).ready on_load


