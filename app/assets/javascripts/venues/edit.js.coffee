town_autocomplete = {}
street_autocomplete = {}

on_load = ->
  load
    controllers:
      venues: ["edit"]
  , (controller, action) ->
    initialize_selects = ->
      $('.venue-types-select').select2()
      $('.currency-select').select2()
      country = $("#venue_country_code").val()
      town_autocomplete = new google.maps.places.Autocomplete(document.getElementById('venue_town'), { types: ['(cities)'], componentRestrictions: {country: country} })
      street_autocomplete = new google.maps.places.Autocomplete(document.getElementById('venue_street'), { types: ['address'], componentRestrictions: {country: country} })

      google.maps.event.addListener town_autocomplete, 'place_changed', ->
        town = town_autocomplete.getPlace().address_components[0]
        if town
          $('#venue_town').val(town.long_name)

      google.maps.event.addListener street_autocomplete, 'place_changed', ->
        street = street_autocomplete.getPlace().address_components[0]
        if street
          $('#venue_street').val(street.long_name)



    initialize_listeners = ->
      $('#venue_postal_code, #venue_country_id, #venue_street, #venue_town').change ->
        getLatLong()

      $("#venue_country_code").change (event, value) ->
        country = $(event.target).val()
        town_autocomplete.setComponentRestrictions({country: country})
        street_autocomplete.setComponentRestrictions({country: country})
        $('#venue_street').val("")
        $('#venue_town').val("")
      return

    initialize_popovers = ->
      options = {
        placement: (context, source) ->
          position = $(source).offset()
          if (position.left > 160)
              return "left"
          if (position.left < 160)
              return "right"
          if (position.top < 110)
              return "bottom"
          return "top"
      }
      $('#email-popover').popover(options)
      $('#phone-popover').popover(options)
      $('#street-popover').popover(options)
      $('#postal-code-popover').popover(options)
      #$('#emergency-popover').popover(options)

    getLatLong = ->
      country = $('#s2id_venue_country_id  .select2-chosen').html()
      street = $('#venue_street').val()
      town = $('#venue_town').val()
      address = street + ' ' + town + ' ' + country
      if country == "" || street == "" || town == ""
        return
      getLatLongFromAddress(address.replace(RegExp(' ', 'g'), '+'))
      return

    getLatLongFromAddress = (address) ->
      geocoder = new google.maps.Geocoder();
      geocoder.geocode { 'address': address }, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          lat = results[0].geometry.location.lat()
          lng = results[0].geometry.location.lng()
          $('#venue_latitude').val(lat)
          $('#venue_longitude').val(lng)
        else
          console.log('Geocode was not successful for the following reason: ' + status)
        return
      return

    initialize_selects()
    initialize_listeners()
    initialize_popovers()
  return
$(document).ready on_load
