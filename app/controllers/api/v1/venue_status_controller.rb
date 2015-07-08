module Api
  module V1
    class VenueStatusController < ApiController
      # This controller will simply tell if each of the steps in the validation process are
      # done or not

      def status
        @venue = Venue.find(params[:id])
        render json: {
          first_step: first_step_done, second_step: second_step_done,
          third_step: third_step_done, fourth_step: fourth_step_done,
          fifth_step: fifth_step_done, sixth_step: sixth_step_done,
          percentage: calculate_percentage * 100
        }
      end

      private

      def calculate_percentage
        arr = [first_step_done, second_step_done, fourth_step_done,
               fifth_step_done, sixth_step_done].map { |val| val ? 1 : 0 }
        arr.reduce(&:+).to_f / arr.size
      end

      def first_step_done
        VenueFirstStepEdition.new(@venue).valid?
      end

      def second_step_done
        VenueDetailStepEdition.new(@venue).valid?
      end

      # This step was removed from the percentaje because the venue could not have
      # an amenity, so is like a optional field.
      def third_step_done
        VenueAmenitiesValidator.new(@venue).valid?
      end

      def fourth_step_done
        @venue.photos.present?
      end

      def fifth_step_done
        account = @venue.collection_account
        account.present? && account.respond_to?(:accepted?) && account.accepted?
      end

      def sixth_step_done
        @venue.spaces.active.present?
      end
    end
  end
end
