module Api
  module V1
    class ReceiptController < ApiController
      include RepresentedHelper
      before_action :authenticate_user!

      def create
        booking = Booking.find_by(id: params[:booking_id])
        return record_not_found unless booking.present?
        receipt_context = ReceiptContext.new(current_represented)
        return forbidden unless receipt_context.can_create_receipt?(booking)
        render_nothing if receipt_context.create_receipt(booking)
      end

    end
  end
end
