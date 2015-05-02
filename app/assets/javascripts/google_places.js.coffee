on_load = ->
  element = $('#search')[0]
  if $('body')[0].dataset.controller == 'landing' || $('body')[0].dataset.action == 'search_mobile'
    element = $('.input-search-landing')[0]

  new google.maps.places.Autocomplete(element, { types: ['geocode'] })
  $('#search').change ->
    $('#menu-search-form').submit()

$(document).ready on_load


