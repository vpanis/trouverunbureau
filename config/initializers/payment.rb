# for travis
if Rails.env.test?
  braintree = OpenStruct.new(
    merchant_account: "yzj3y44bqwpcdym9",
    minutes_to_poll_for_escrow_status: 0.01,
    hours_to_poll_for_verify_release: 0.01,
    append_random_to_accounts_ids: true)
  deskspotting = OpenStruct.new(
    fee: 0.15,
    payouts_attempts: 3,
    notification_attempts: 3,
    deposit_days: 3,
    cancellation_penalty_fee: 0.15,
    cancellation_less_than_24_hours_in_hours: 24,
    cancellation_less_than_a_month_in_hours: 120,
    cancellation_more_than_a_month_in_hours: 240,
    cancellation_percentage_to_the_venue_in_more_than_a_month: 0.5 )
  mangopay = OpenStruct.new(
    client_id: "deskspotting-dev",
    base_url: "https://api.sandbox.mangopay.com"
  )
else
  braintree = AppConfiguration.for(:braintree)
  deskspotting = AppConfiguration.for(:deskspotting)
  mangopay = AppConfiguration.for(:mangopay)
end

Deskspotting::Application.configure do
  config.base_url = AppConfiguration.for(:deskspotting).base_url
  config.payment = OpenStruct.new(
    deskspotting_fee: deskspotting.fee.to_f,
    braintree: OpenStruct.new(
      merchant_account_id: braintree.merchant_account,
      time_to_poll_for_escrow_status: braintree.minutes_to_poll_for_escrow_status.to_i.minutes,
      hours_to_poll_for_verify_release: braintree.hours_to_poll_for_verify_release.to_i.hours,
      append_random_to_accounts_ids: braintree.append_random_to_accounts_ids == 'true'
    ),
    mangopay: OpenStruct.new(
      client_id: mangopay.client_id,
      base_url: mangopay.base_url
    ),
    cancellation: OpenStruct.new(
      penalty_fee: deskspotting.cancellation_penalty_fee.to_f,
      less_than_24_hours_in_hours: deskspotting.cancellation_less_than_24_hours_in_hours.to_i,
      less_than_a_month_in_hours: deskspotting.cancellation_less_than_a_month_in_hours.to_i,
      more_than_a_month_in_hours: deskspotting.cancellation_more_than_a_month_in_hours.to_i,
      percentage_to_the_venue_in_more_than_a_month: deskspotting.cancellation_percentage_to_the_venue_in_more_than_a_month.to_f
    ),
    payouts_attempts: deskspotting.payouts_attempts.to_i,
    notification_attempts: deskspotting.notification_attempts.to_i,
    deposit_days: 3.to_i
  )
end
