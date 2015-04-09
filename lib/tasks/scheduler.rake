namespace :scheduler do
  desc 'Expire the bookings which pending_payment state changed a day ago'
  task expire_bookings: :environment do
    ExpireBookingsWorker.perform_async()
  end

  desc 'Destroy the mangopay_credit_cards which registrations was not completed'
  task destroy_mangopay_invalid_cards: :environment do
    Payments::Mangopay::DestroyInvalidCreditCardWorker.perform_async()
  end
end
