braintree = AppConfiguration.for(:braintree)

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.logger = Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id = braintree.merchant_id
Braintree::Configuration.public_key = braintree.public_key
Braintree::Configuration.private_key = braintree.private_key