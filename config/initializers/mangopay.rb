mangopay = AppConfiguration.for(:mangopay)

MangoPay.configure do |config|
  config.preproduction = mangopay.preproduction != 'false'
  config.client_id = mangopay.client_id
  config.client_passphrase = mangopay.passphrase
end
