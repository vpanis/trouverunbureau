namespace :scheduler do
  desc 'Expire the bookings which pending_payment state changed a day ago'
  task expire_bookings: :environment do
    Resque.enqueue_to(:expire_queue, ExpireBookingsJob)
  end
end