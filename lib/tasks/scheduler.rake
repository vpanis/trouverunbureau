namespace :scheduler do
  desc 'Expire the bookings which pending_payment state changed a day ago'
  task expire_bookings: :enviroment do
    Resque.enqueue_to(:expire_queue, ExpireBookingsJob.new)
  end
end