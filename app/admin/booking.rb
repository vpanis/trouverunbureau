ActiveAdmin.register Booking do

  actions :index
  filter :hold_deposit
  filter :state, collection: Booking.states, as: :select

  member_action :refund, method: :post do
    resource.update_attributes(hold_deposit: false)
    redirect_to admin_bookings_path, notice: 'The deposit will be refunded'
  end

  member_action :pay, method: :post do
    redirect_to admin_bookings_path, notice: 'Can\'t return the deposit' if !b.hold_deposit ||
      resource.payment.deposit_amount_in_wallet == 0 || !(b.paid? || b.cancelled? || b.denied?)

    payout = resource.payment.mangopay_payouts.create(amount: resource.deposit, fee: 0,
      user_id: resource.payment.user_paying_id, represented: resource.owner,
      p_type: MangopayPayout.p_types[:payout_to_user])

    cc = resource.space.venue.collection_account
    Receipt.create(payment: payout, bank_type: cc.bank_type,
                   account_last_4: cc.generic_account_last_4)

    resource.payment.update_attributes(
      next_payout_at: next_payout_at,
      deposit_amount_in_wallet: resource.payment.deposit_amount_in_wallet - payout.amount)

    Payments::Mangopay::TransferPaymentWorker.perform_async(payout.id)

    resource.update_attributes(hold_deposit: false)

    redirect_to admin_bookings_path, notice: 'Paying the deposit to the Host'
  end

  index do
    id_column
    column :hold_deposit do |b|
      (b.hold_deposit) ? 'hold' : 'normal'
    end
    column :deposit
    column :price
    column :guest_email do |b|
      b.owner.email
    end
    column :host_email do |b|
      b.space.venue.owner.email
    end
    column :state
    column 'Actions', class: 'actions-col' do |b|
      if (b.paid? || b.cancelled? || b.denied?) && b.hold_deposit
        span { link_to 'Refund to Guest', refund_admin_booking_path(b), method: 'post' }
        span { '|' }
        span { link_to 'Pay to Host', pay_admin_booking_path(b), method: 'post' }
      end
    end
  end

end
