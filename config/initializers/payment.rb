braintree = AppConfiguration.for(:braintree)

Deskspotting::Application.configure do
  config.payment = OpenStruct.new(
    deskspotting_fee: AppConfiguration.for(:deskspotting).fee,
    braintree: OpenStruct.new(
      merchant_account_id: braintree.merchant_account,
      time_to_poll_for_escrow_status: braintree.minutes_to_poll_for_escrow_status.minutes,
      hours_to_poll_for_verify_release: braintree.hours_to_poll_for_verify_release.hours,
      append_random_to_accounts_ids: braintree.append_random_to_accounts_ids
    )
  )
end
