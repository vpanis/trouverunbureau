#town_autocomplete = {}
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
      street_autocomplete = new google.maps.places.Autocomplete(document.getElementById('venue_street'), { types: ['address'], componentRestrictions: {country: country} })

      google.maps.event.addListener street_autocomplete, 'place_changed', ->
        geometry = street_autocomplete.getPlace().geometry

        if geometry
          lat = geometry.location.lat()
          lng = geometry.location.lng()
          $('#venue_latitude').val(lat)
          $('#venue_longitude').val(lng)

          place = street_autocomplete.getPlace()

          i = 0
          while i < place.address_components.length
            type = place.address_components[i].types[0]
            if type == "locality" || type == "administrative_area_level_3"
              $("#venue_town").val(place.address_components[i].long_name)
            i++


    initialize_listeners = ->

      $("#venue_country_code").change (event, value) ->
        country = $(event.target).val()
        street_autocomplete.setComponentRestrictions({country: country})
        $('#venue_street').val("")
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

    getLatLong = ->
      country = $('#s2id_venue_country_id  .select2-chosen').html()
      street = $('#venue_street').val()
      town = $('#venue_town').val()
      address = street + ' ' + town + ' ' + country
      console.log("address: "+address)
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

    $("#phone").intlTelInput
      allowExtensions: true
      utilsScript: '/utils.js'
    $("#phone").intlTelInput("setNumber", $('#venue_phone').val());

    $('#save-venue').click ->
      $('#venue_phone').val($('#phone').intlTelInput("getNumber"))

    initialize_selects()
    initialize_listeners()
    initialize_popovers()
  return
$(document).ready on_load
