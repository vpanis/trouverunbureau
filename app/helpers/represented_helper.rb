module RepresentedHelper

  def current_represented
    return @current_represented if @current_represented
    return nil unless user_signed_in?

    @current_represented = current_user
    organization = Organization.find_by_id(session[:current_organization_id])
    @current_represented = organization if organization.present? &&
      current_user.user_can_write_in_name_of(organization)
    @current_represented
  end

  def user_can_read_client_reviews?(entity, id)
    return false unless user_signed_in?
    # Me asking for Me, Me as Org asking for Org, and Me as Org asking for Me
    return true if (current_represented.id == id &&
      current_represented.class == entity) || (current_user.id == id && entity == User)
    # My clients
    !Booking.joins { space.venue }
      .where { (owner_id == my { id }) & (owner_type == my { entity }) }
      .where { space.venue.owner == my { current_represented } }.empty?
  end

  def other_members_current_represented
    current_user.organizations + [current_user] - [@current_represented]
  end

  def new_messages
    return @new_messages if @new_messages
    return 0 unless current_user.present?
    @new_messages = BookingManager.bookings_with_news(current_represented).size
  end

end
