class VenueDetailsController < VenuesController

  def details
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @modify_day_hours = load_day_hours
    @custom_hours = custom_hours?
    @professions_options = profession_options
  end

  def save_details
    @venue = Venue.find(params[:id])
    return unless can_edit?
    # return render nothing: true, status: 412 unless VenueContext.new(@venue, current_represented)
    #                                                           .update_venue(object_params)
    @venue.update_attributes!(object_params)
    update_professions!
    redirect_to amenities_venue_path(@venue)
  end

  private

  def amenities_params
    params.require(:venue).permit(amenities: [])[:amenities].reject!(&:empty?)
  end

  def update_professions!
    return unless  object_params['professions'].present?
    professions = object_params['professions'].gsub(/^\{+|\}+$/, '').split(',')
    @venue.update_attributes!(professions: professions)
  end

  def load_day_hours
    day_hours = []
    @venue.day_hours.each { |dh| day_hours[dh.weekday] = dh }
    (0..6).each do |index|
      day_hours[index] = VenueHour.new(weekday: index) unless day_hours[index].present?
    end
    day_hours
  end

  def custom_hours?
    previous = @modify_day_hours[0]
    (1..4).each do |index|
      current = @modify_day_hours[index]
      return true if current.from != previous.from || current.to != previous.to
      previous = current
    end
    false
  end

end
