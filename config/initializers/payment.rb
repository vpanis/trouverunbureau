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
    cancellation: OpenStruct.new(
      penalty_fee: 0.15,
      less_that_24_hours_in_hours: 24,
      less_that_a_month_in_hours: 120,
      more_than_a_month_in_hours: 240,
      percentage_to_the_venue_in_more_than_a_month: 0.5))
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
      penalty_fee: deskspotting.cancellation.penalty_fee.to_f,
      less_that_24_hours_in_hours: deskspotting.cancellation.less_that_24_hours_in_hours_to_i,
      less_that_a_month_in_hours: deskspotting.cancellation.less_that_a_month_in_hours.to_i,
      more_than_a_month_in_hours: deskspotting.cancellation.more_than_a_month_in_hours.to_i,
      percentage_to_the_venue_in_more_than_a_month: deskspotting.cancellation.percentage_to_the_venue_in_more_than_a_month.to_f
    ),
    payouts_attempts: deskspotting.payouts_attempts.to_i
  )
end
