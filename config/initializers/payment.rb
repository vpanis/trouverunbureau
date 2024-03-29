# for travis
if Rails.env.test?
  aig = OpenStruct.new(
    insurance_enabled?: true,
    mangopay_wallet_id: 1,
    mangopay_account_id: 1,
    fee_less_than_1_month: 0.35,
    fee_more_than_1_month: 1.98
  )
  braintree = OpenStruct.new(
    merchant_account: "yzj3y44bqwpcdym9",
    minutes_to_poll_for_escrow_status: 0.01,
    hours_to_poll_for_verify_release: 0.01,
    append_random_to_accounts_ids: true)
  deskspotting = OpenStruct.new(
    fee: 0.2,
    fee2: 0.1,
    payouts_attempts: 3,
    base_url: "http://localhost:3000",
    hours_from_check_in_out_for_rate: 1,
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
  aig = AppConfiguration.for(:aig)
  braintree = AppConfiguration.for(:braintree)
  deskspotting = AppConfiguration.for(:deskspotting)
  mangopay = AppConfiguration.for(:mangopay)
end

TrouverUnBureau::Application.configure do
  config.hours_from_check_in_out_for_rate = deskspotting.hours_from_check_in_out_for_rate.to_i
  config.base_url = deskspotting.base_url
  config.payment = OpenStruct.new(
    aig: OpenStruct.new(
      insurance_enabled?: aig.insurance_enabled == 'true',
      mangopay_wallet_id: aig.mangopay_wallet_id.try(:to_i),
      mangopay_account_id: aig.mangopay_account_id.try(:to_i),
      fee_less_than_1_month: aig.fee_less_than_1_month.try(:to_f) || 0.35,
      fee_more_than_1_month: aig.fee_more_than_1_month.try(:to_f) || 1.98
    ),
    deskspotting_fee: deskspotting.fee.try(:to_f) || 0.2,
    deskspotting_fee2: deskspotting.fee2.try(:to_f) || 0.1,
    deskspotting_fee3: deskspotting.fee3.try(:to_f) || 0.05,
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

PayConf = Rails.configuration.payment
