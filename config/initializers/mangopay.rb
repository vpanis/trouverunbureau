mangopay = AppConfiguration.for(:mangopay)

MangoPay.configure do |config|
  config.preproduction = ENV["MANGOPAY_PREPRODUCTION"] != 'false'
  config.client_id = ENV["MANGOPAY_CLIENT_ID"]
  config.client_passphrase = ENV["MANGOPAY_PASSPHRASE"]
end
