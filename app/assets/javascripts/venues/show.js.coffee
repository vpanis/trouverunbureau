on_load = ->
  $('#venue-info-tab').hide()
  $('#venue-workspaces-tab').show()
  $('#venue-info-selector').removeClass('active')
  $('#venue-workspaces-selector').addClass('active')

  $('#venue-info-selector').click ->
    $('#venue-info-tab').show()
    $('#venue-workspaces-tab').hide()
    $('#venue-info-selector').addClass('active')
    $('#venue-workspaces-selector').removeClass('active')
  $('#venue-workspaces-selector').click ->
    $('#venue-info-tab').hide()
    $('#venue-workspaces-tab').show()
    $('#venue-info-selector').removeClass('active')
    $('#venue-workspaces-selector').addClass('active')
$(document).ready on_load
