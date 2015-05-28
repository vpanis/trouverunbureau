module Api
  module V1
    class VenuesController < ApiController

      def report
        @venue = Venue.find(params[:id])
        @venue.update_attributes!(status: Venue.statuses[:reported])
        render_nothing
      end
    end
  end
end
