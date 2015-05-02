if Rails.env.test?
  braintree = OpenStruct.new(
    merchant_account: "yzj3y44bqwpcdym9",
    minutes_to_poll_for_escrow_status: 0.01,
    hours_to_poll_for_verify_release: 0.01,
    append_random_to_accounts_ids: true)
  deskspotting = OpenStruct.new(fee: 0.15)
else
  braintree = AppConfiguration.for(:braintree)
  deskspotting = AppConfiguration.for(:deskspotting)
end

Deskspotting::Application.configure do
  config.payment = OpenStruct.new(
    deskspotting_fee: deskspotting.fee.to_f,
    braintree: OpenStruct.new(
      merchant_account_id: braintree.merchant_account,
      time_to_poll_for_escrow_status: braintree.minutes_to_poll_for_escrow_status.to_i.minutes,
      hours_to_poll_for_verify_release: braintree.hours_to_poll_for_verify_release.to_i.hours,
      append_random_to_accounts_ids: braintree.append_random_to_accounts_ids == 'true'
    )
  )
end
