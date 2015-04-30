class BraintreePaymentWorker
  include Sidekiq::Worker

  def perform(booking_id, payment_token, user_id, represented_id, represented_type)
    init_log(booking_id, payment_token, user_id, represented_id, represented_type)
    @booking = Booking.includes(space: { venue: [:collection_account] }).find_by_id(booking_id)
    return unless represented_type.in? %w(User Organization)
    @represented = represented_type.constantize.find_by_id(represented_id)
    # impossible, but...
    return unless @booking.present? && @represented.present? && User.exists?(user_id)

    compute_braintree_response(user_id, braintree_transaction(payment_token))
  end

  private

  def init_log(booking_id, payment_token, user_id, represented_id, represented_type)
    str = "BraintreePaymentWorker on booking_id: #{booking_id}, payment_token: #{payment_token}, "
    str += "user_id: #{user_id}, represented_id: #{represented_id}, "
    str += "represented_type: #{represented_type}"
    Rails.logger.info(str)
  end

  def declined_log(booking_id)
    Rails.logger.warn("BraintreePaymentWorker declined_payment for booking_id: #{booking_id}")
  end

  def compute_braintree_response(user_id, braintree_response)
    if braintree_response.success?
      accepted_payment(braintree_response)
      BraintreeEscrowAcceptedWorker.perform_in(escrow_polling_time, @booking.id, user_id)
    else
      BookingManager.change_booking_status(User.find(user_id), @booking,
                                           Booking.states[:pending_payment])
      declined_payment(braintree_response)
    end
  end

  def accepted_payment(braintree_response)
    customer_id = braintree_response.transaction.customer_details.id
    @represented.update_attributes(payment_customer_id: customer_id) unless
      @represented.payment_customer_id.present?
    update_payment_attributes(braintree_response.transaction)
  end

  def update_payment_attributes(transaction)
    ccd = transaction.credit_card_details
    @booking.payment.update_attributes(card_type: ccd.card_type,
                                       card_last_4: ccd.last_4,
                                       card_expiration_date: ccd.expiration_date,
                                       transaction_id: transaction.id,
                                       transaction_status: transaction.status,
                                       escrow_status: transaction.escrow_status)
  end

  def declined_payment(braintree_response)
    declined_log(@booking.id)
    @booking.payment.update_attributes(transaction_status: 'error',
                                       error_message: braintree_response.message)
  end

  def braintree_transaction(payment_token)
    attributes = payment_atributes(payment_token)
    add_new_customer_attributes(attributes, generate_customer_id) unless
      @represented.payment_customer_id.present?
    Braintree::Transaction.sale(attributes)
  end

  def payment_atributes(payment_token)
    { amount: @booking.price,
      merchant_account_id: @booking.space.venue.collection_account.merchant_account_id,
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

  def generate_customer_id
    str = "#{@represented.class.to_s.first}-#{@represented.id}"
    str = SecureRandom.hex(8) + '-' + str if append_random
    str
  end

  def escrow_polling_time
    Rails.configuration.payment.braintree.time_to_poll_for_escrow_status
  end

  def append_random
    Rails.configuration.payment.braintree.append_random_to_accounts_ids
  end

end
