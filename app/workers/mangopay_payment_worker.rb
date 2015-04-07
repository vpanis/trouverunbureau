class MangopayPaymentWorker
  include Sidekiq::Worker

  @deskspotting = AppConfiguration.for(:deskspotting)

  def perform(booking_id, credit_card_id, user_id, return_url)
    init_log(booking_id, credit_card, user_id)
    @booking = Booking.includes(space: { venue: [:collection_account] }).find_by_id(booking_id)
    # impossible, but...
    return unless require_validations?(user_id)
    @represented = @booking.owner
    @credit_card = MangopayCreditCard.find_by_id(credit_card_id)
    return unless valid_credit_card?(user_id)

    save_payment(mangopay_transaction(@credit_card.credit_card_id, return_url))
  rescue MangoPay::ResponseError => e
    save_payment_error(e.errors, user_id)
  end

  private

  def init_log(booking_id, credit_card, user_id)
    str = "MangoPaymentWorker on booking_id: #{booking_id}, credit_card: #{credit_card}, "
    str += "user_id: #{user_id}"
    Rails.logger.info(str)
  end

  def valid_credit_card?(user_id)
    return true if @credit_card.present? && @credit_card.created?
    save_payment_error('Credit card not available', user_id)
    false
  end

  def mangopay_transaction(credit_card, return_url)
    currency = @booking.space.venue.currency.upcase
    MangoPay::PayIn::Card::Direct.create(
      AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
      DebitedFunds: {
        Currency: currency, Amount: @booking.price * 100
      }, Fees: {
        Currency: currency, Amount: @booking.fee * 100
      }, CreditedWalletId: @booking.owner.mangopay_payment_account.wallet_id, CardId: credit_card,
      SecureMode: 'DEFAULT', SecureModeReturnURL: absolute_return_url(return_url))
  end

  def save_payment(transaction_data, return_url)
    redirect = transaction_data['SecureModeRedirectURL'] || absolute_return_url(return_url)
    @booking.payment.update_attributes(
      transaction_id: transaction_data['Id'],
      transaction_status: transaction_data['Status'],
      redirect_url: redirect)
  end

  def save_payment_error(e, user_id)
    @booking, _cerr = BookingManager.change_booking_status(User.find(user_id), @booking,
                                                           Booking.states[:pending_payment])
    @booking.payment.update_attributes(error_message: e.to_s,
                                       transaction_status: 'FAILED')
  end

  def require_validations?(user_id)
    @booking.present? && @booking.owner.present? && User.exists?(user_id)
  end

  def absolute_return_url(return_url)
    @deskspotting.base_url + return_url
  end
end
