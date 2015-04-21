on_load = () ->
  $("#submit-invitation").click (event) ->
    $('#mail').text($("#input-mail")[0].value)
    $('#alert').removeClass('alert--hidden')
$(document).ready on_load
