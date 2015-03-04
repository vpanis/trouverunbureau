module Api
  module V1
    class ReceiptController < ApiController
      include RepresentedHelper
      before_action :authenticate_user!

      def create
        booking = Booking.find_by(id: params[:id])
        return record_not_found unless booking.present?
        receipt_context = ReceiptContext.new(current_represented)
        return forbidden unless receipt_context.can_create_receipt?(booking)
        render_nothing if receipt_context.create_receipt(booking)
      end

      def show
        booking = Booking.find_by(id: params[:id])
        return record_not_found unless booking.present?
        receipt_context = ReceiptContext.new(current_represented)
        return forbidden unless receipt_context.owner?(booking)
        result = receipt_context.create_receipt(booking)
        byebug
        render json: ReceiptSerializer.new(result), status: 200 if result.present?
      end
    end
  end
end
