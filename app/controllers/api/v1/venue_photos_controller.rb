module Api
  module V1
    class VenuePhotosController < ApiController
      before_action :authenticate_user!

      def create
        return create_space_photo if params[:space_id].present?
        create_venue_photo
      end

      def destroy
        venue_photo = VenuePhoto.find_by(id: params[:id])
        return record_not_found unless venue_photo.present?
        return forbidden unless VenueContext.new(venue_photo.venue, current_represented).owner?
        return forbidden if venue_photo.space_id != params[:space_id]
        check_if_space_is_active(venue_photo.space)
        venue_photo.destroy!
        render nothing: true, status: 200
      end

      private

      def check_if_space_is_active(space)
        return unless space.present?
        # set to inactive if the space has only one photo (the one that will be destroyed...)
        space.update_attributes(active: false) if space.photos.count == 1
      end

      def create_space_photo
        @space = Space.find_by(id: params[:space_id])
        venue = Venue.find_by(id: params[:venue_id])
        return record_not_found unless photo_belongs_to_space_and_venue?(@space, venue)
        return forbidden unless SpaceContext.new(@space, current_represented).owner?
        create_photo!
      end

      def create_venue_photo
        venue = Venue.find_by(id: params[:venue_id])
        return record_not_found unless venue.present?
        return forbidden unless VenueContext.new(venue, current_represented).owner?
        create_photo!
      end

      def create_photo!
        venue_photo = VenuePhoto.create!(photo_params)
        @space.update_attributes(active: true) if @space.present?
        render json: { id: venue_photo.id, photo: venue_photo.photo.url }, status: 201
      end

      def photo_params
        params.permit(:venue_id, :space_id, :photo)
      end

      def photo_belongs_to_space_and_venue?(space, venue)
        space_id = photo_params[:space_id].to_i
        venue_id = photo_params[:venue_id].to_i
        return false unless space.present? && venue.present?
        space.id == space_id && space.venue.id == venue.id && space.venue.id == venue_id
      end

    end
  end
end
