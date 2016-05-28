# This is a manifest file that'll be compiled into including all the files listed below.
# Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
# be included in the compiled file accessible from http://example.com/assets/application.js
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
#= require jquery
#= require jquery_ujs
#= require loadjs
#= require jquery.turbolinks
#= require active_admin
#= require twitter/bootstrap
#= require bootstrap
#= require retina
#= require masonry.pkgd
#= require angular
#= require angular-cookies
#= require lodash
#= require restangular
#= require angular-ui-bootstrap-tpls
#= require select2
#= require braintree
#= require intlTelInput.min
#= require mangopay-kit
#= require ./payment_modes/mangopay_dropin
#= require_directory .
#= require signup
#= require google_places
#= require_tree ./bookings/
#= require_tree ./landing/
#= require_tree ./organizations/
#= require_tree ./reviews/
#= require_tree ./spaces/
#= require_tree ./users/
#= require_tree ./venues/
#= require_tree ./payments/
#= require_tree ./angular/controllers
#= require_tree ./referral/
#= require angular-translate
#= require footer
#= require jquery.inputmask
#= require jquery.inputmask.extensions
#= require jquery.inputmask.numeric.extensions
#= require jquery.inputmask.date.extensions

# global functions, available in all views
window.hide_spinner = hide_spinner = ->
  $('.spinner-container').hide()

window.show_spinner = show_spinner =  ->
  $('.spinner-container').show()
