namespace :scheduler do
  desc 'Expire the bookings which pending_payment state changed a day ago'
  task expire_bookings: :environment do
    ExpireBookingsWorker.perform_async()
  end
end
