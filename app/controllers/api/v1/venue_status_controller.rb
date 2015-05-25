module Api
  module V1
    class VenueStatusController < ApiController
      # This controller will simply tell if each of the steps in the validation process are
      # done or not

      def first_step
        render json: { done: first_step_done }
      end

      def second_step
        render json: { done: second_step_done }
      end

      def third_step
        render json: { done: third_step_done }
      end

      def fourth_step
        render json: { done: fourth_step_done }
      end

      def fifth_step
        render json: { done: fifth_step_done }
      end

      def sixth_step
        render json: { done: sixth_step_done }
      end

      def percentage
        arr = [first_step_done, second_step_done, third_step_done, fourth_step_done,
               fifth_step_done, sixth_step_done].map { |val| val ? 1 : 0 }
        percentage = arr.reduce(&:+).to_f / arr.size
        render json: { percentage: percentage * 100 }
      end

      private

      def first_step_done
        VenueFirstStepEdition.new(Venue.find(params[:id])).valid?
      end

      def second_step_done
        VenueDetailStepEdition.new(Venue.find(params[:id])).valid?
      end

      def third_step_done
        VenueAmenitiesValidator.new(Venue.find(params[:id])).valid?
      end

      def fourth_step_done
        Venue.find(params[:id]).photos.present?
      end

      def fifth_step_done
        Venue.find(params[:id]).collection_account.present?
      end

      def sixth_step_done
        Venue.find(params[:id]).spaces.present?
      end
    end
  end
end
