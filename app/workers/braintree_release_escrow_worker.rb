class BraintreeReleaseEscrowWorker
  include Sidekiq::Worker

  def perform(payment_id)
    init_log(payment_id)
    @payment = BraintreePayment.find_by_id(payment_id)
    return unless @payment.present? # impossible, but...

    # Can't release a fund if the transaction is not held
    if @payment.escrow_status == Braintree::Transaction::EscrowStatus::Held
      release_from_escrow
    elsif @payment.escrow_status == Braintree::Transaction::EscrowStatus::HoldPending
      # retries in 2 * the time waited to ask if the escrow is held or not
      BraintreeReleaseEscrowWorker.perform_in(escrow_polling_time * 2, payment_id)
    else
      cant_release(@payment)
    end
  end

  private

  def init_log(payment_id)
    Rails.logger.info("BraintreeReleaseEscrowWorker on payment_id: #{payment_id}")
  end

  def cant_release
    cant_release_log
    @payment.update_attributes(error_message: 'Can\'t release escrow in this escrow_status')
  end

  def cant_release_log
    str = "BraintreeReleaseEscrowWorker invalid state on releasing payment_id: #{payment.id}, "
    str += "escrow_status: #{@payment.escrow_status}"
    Rails.logger.warn(str)
  end

  def release_from_escrow
    release_result = Braintree::Transaction.release_from_escrow(@payment.transaction_id)
    # If it tries to release the same payment 2 times
    return unless release_result.success?
    @payment.update_attributes(escrow_status: release_result.transaction.escrow_status)
    BraintreeVerifyReleasedWorker.perform_in(v_release_polling_time, @payment.id)
  end

  def escrow_polling_time
    Rails.configuration.payment.braintree.time_to_poll_for_escrow_status
  end

  def v_release_polling_time
    Rails.configuration.payment.braintree.hours_to_poll_for_verify_release
  end

end
