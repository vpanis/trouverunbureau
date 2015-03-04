Deskspotting::Application.configure do
  config.payment = OpenStruct.new(
    deskspotting_fee: 15,
    braintree: OpenStruct.new(
      merchant_account_id: AppConfiguration.for(:braintree).merchant_account,
      time_to_poll_for_escrow_status: 5.minutes
    )
  )
end
