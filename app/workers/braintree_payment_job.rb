class BraintreePaymentJob
  @queue = :braintree_payments
  @merchant_account_id = Rails.configuration.payment.braintree.merchant_account
  @escrow_polling_time = Rails.configuration.payment.braintree.time_to_poll_for_escrow_status
  @deskspotting_fee = @escrow_polling_time = Rails.configuration.payment.deskspotting_fee

  def self.perform(booking_id, payment_token, user_id)
    @booking = Booking.find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

    compute_braintree_response(braintree_transaction(payment_token))
  end

  private

  def compute_braintree_response(braintree_response)
    if braintree_response.success?
      @booking.payment = accepted_payment(braintree_response.transaction)
      Resque.enqueue_in(@escrow_polling_time, BraintreeEscrowAcceptedJob, @booking.id, user_id)
    else
      BookingManager.change_booking_status(User.find(user_id), @booking,
                                           Booking.states[:pending_payment])
      @booking.payment = declined_payment(braintree_response)
    end
    @booking.save
  end

  def accepted_payment(transaction)
    BraintreePayment.create(transaction_id: transaction.id, transaction_status: transaction.status,
                            escrow_status: transaction.escrow_status)
  end

  def declined_payment(braintree_response)
    BraintreePayment.create(transaction_status: 'error', error_message: braintree_response.message)
  end

  def braintree_transaction(payment_token)
    Braintree::Transaction.sale(
      amount: @booking.price,
      merchant_account_id: @merchant_account_id,
      payment_method_nonce: payment_token,
      options: {
        submit_for_settlement: true,
        hold_in_escrow: true
      },
      service_fee_amount: calculate_fee(@booking.price)
    )
  end

  def calculate_fee(price)
    price * @deskspotting_fee
  end
end
