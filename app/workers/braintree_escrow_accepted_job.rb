class BraintreeEscrowAcceptedJob
  @queue = :braintree_escrow_accepted

  def self.perform(transaction_id, booking_id)
    @booking = Booking.find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

  end
end
