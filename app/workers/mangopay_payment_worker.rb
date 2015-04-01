class MangopayPaymentWorker
  include Sidekiq::Worker

  def perform(booking_id, credit_card, user_id, represented_id, represented_type)
    init_log(booking_id, credit_card, user_id, represented_id, represented_type)
    @booking = Booking.includes(space: { venue: [:collection_account] }).find_by_id(booking_id)
    return unless represented_type.in? %w(User Organization)
    @represented = represented_type.constantize.find_by_id(represented_id)
    # impossible, but...
    return unless @booking.present? && @represented.present? && User.exists?(user_id)

    compute_braintree_response(user_id, mangopay_transaction(credit_card))
  end

  private

  def init_log(booking_id, credit_card, user_id, represented_id, represented_type)
    str = "MangoPaymentWorker on booking_id: #{booking_id}, credit_card: #{credit_card}, "
    str += "user_id: #{user_id}, represented_id: #{represented_id}, "
    str += "represented_type: #{represented_type}"
    Rails.logger.info(str)
  end

        # params[:id]
        # params[:card_id]
        # MangoPay::PayIn::Card::Direct.create({
        #   AuthorId: "6249103",
        #   DebitedFunds: {
        #     Currency: "EUR",
        #     Amount: 140000
        #   },
        #   Fees: {
        #     Currency: "EUR",
        #     Amount: 14000
        #   },
        #   CreditedWalletId: "6132122",
        #   CardId: "6251237",
        #   SecureMode:"DEFAULT",
        #   SecureModeReturnURL:"http://requestb.in/1ch474m1"
        # })
end
