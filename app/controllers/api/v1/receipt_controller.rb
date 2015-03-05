module Api
  module V1
    class ReceiptController < ApiController
      include RepresentedHelper
      before_action :authenticate_user!

      def create
        booking = Booking.find_by(id: params[:id])
        return record_not_found unless booking.present?
        receipt_context = ReceiptContext.new(current_represented)
        return forbidden unless receipt_context.owner?(booking)
        return wrong_preconditions unless receipt_context.create_receipt(booking)
        render_nothing
      end

      def show
        booking = Booking.find_by(id: params[:id])
        return record_not_found unless booking.present?
        receipt_context = ReceiptContext.new(current_represented)
        return forbidden unless receipt_context.authorized?(booking)
        result = receipt_context.get_receipt(booking)
        return wrong_preconditions unless result.present?
        render json: ReceiptSerializer.new(result), status: 200
      end
    end
  end
end
