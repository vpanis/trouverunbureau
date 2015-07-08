class SendReviewsMailWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    bookings_for_reviews.each do |booking|
      NotificationsMailer.delay.host_review_email(booking.id) unless booking.client_review.present?
      NotificationsMailer.delay.guest_review_email(booking.id) unless booking.venue_review.present?
    end
  end

  # Mangopay for now.
  # Search every booking that the check-in or check-out is in x hours from the current date
  def bookings_for_reviews
    Booking.includes(:client_review, :venue_review, :owner, space: [venue: [:owner]])
      .joins('INNER JOIN spaces ON spaces.id = bookings.space_id')
      .joins('INNER JOIN venues ON venues.id = spaces.venue_id')
      .joins('INNER JOIN time_zones ON time_zones.id = venues.time_zone_id')
      .where("state IN (:states) AND (((bookings.from + (interval '1 second' *
        time_zones.seconds_utc_difference)) BETWEEN :t1 AND :t2) OR ((bookings.to +
        (interval '1 second' * time_zones.seconds_utc_difference)) BETWEEN :t1 AND :t2))",
             states: [Booking.states[:paid], Booking.states[:cancelled], Booking.states[:denied]],
             t1: Time.current.advance(hours: (hours_from_check_in_out + 1) * (-1)),
             # second less because BETWEEN includes both dates
             t2: Time.current.advance(hours: hours_from_check_in_out * (-1)), seconds: -1)
  end

  def hours_from_check_in_out
    Rails.configuration.hours_from_check_in_out_for_rate
  end
end
