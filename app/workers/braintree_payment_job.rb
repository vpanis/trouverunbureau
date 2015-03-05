class BraintreePaymentJob
  @queue = :braintree_payments
  @merchant_account_id = Rails.configuration.payment.braintree.merchant_account
  @escrow_polling_time = Rails.configuration.payment.braintree.time_to_poll_for_escrow_status
  @deskspotting_fee = Rails.configuration.payment.deskspotting_fee
  @append_random = Rails.configuration.payment.braintree.append_random_to_accounts_ids

  def self.perform(booking_id, payment_token, user_id, represented_id, represented_type)
    @booking = Booking.find_by_id(booking_id)
    return unless represented_type.in? %w(User Organization)
    @represented = represented_type.constantize.find_by_id(represented_id)
    return unless @booking.present? && @represented && User.exists?(user_id) # impossible, but...

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
    attributes = payment_atributes(payment_token)
    unless @represented.payment_customer_id.present?
      generate_and_save_customer_id
      add_new_customer_attributes(attributes, @represented.payment_customer_id)
    end
    Braintree::Transaction.sale(attributes)
  end

  def payment_atributes(payment_token)
    { amount: @booking.price,
      merchant_account_id: @represented.payment.merchant_account_id,
      payment_method_nonce: payment_token,
      options: {
        submit_for_settlement: true,
        hold_in_escrow: true
      },
      service_fee_amount: @booking.fee
    }
  end

  def add_new_customer_attributes(attributes, customer_id)
    attributes[:customer] = {
      id: customer_id
    }
    attributes[:options][:store_in_vault_on_success] = true
  end

  def calculate_fee(price)
    price * @deskspotting_fee
  end

  def generate_and_save_customer_id
    str = "#{@represented.class}-#{@represented.id}"
    str = SecureRandom.hex + '-' + str if @append_random
    represented.update_attributes(payment_customer_id: str)
  end

end
