$(document).ready ->
  $('#change_language').bind 'ajax:complete', ->
    location.reload()
  $('#language-select').change ->
    $('#change_language').submit()
