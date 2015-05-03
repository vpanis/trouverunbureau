class SpaceBookingInquiryController < ModelController
  include RepresentedHelper
  before_action :authenticate_user!

  def inquiry
    @space = Space.includes(:venue).find(params[:id])
    @day_hours = @space.venue.day_hours.to_json(only: [:weekday, :from, :to])
    @booking = Booking.new(space: @space, owner: current_represented)
  end

  def create_booking_inquiry
    return render :inquiry, status: 400 unless handle_booking_type
    @booking, @custom_error = create_booking
    if @booking.valid? && @custom_error.empty?
      create_booking_message
      return redirect_to inbox_user_path(current_represented)
    end
    @booking_errors = @booking.errors
    @space = Space.includes(:venue).find(params[:id])
    @day_hours = @space.venue.day_hours.to_json(only: [:weekday, :from, :to])
    render :inquiry, status: 400
  end

  private

  def create_booking_message
    Message.create!(
      m_type: Message.m_types[:text],
      user: current_user,
      represented: current_represented,
      booking: @booking,
      text: params[:message]
    ) if params[:message].present?
  end

  def handle_booking_type
    if params[:booking_type].in?(%w(hour day month))
      send("#{params[:booking_type]}_type_booking")
    else
      false
    end
  end

  def hour_type_booking
    hour_date_generator
    return false if @from_date.nil? || @to_date.nil?
    if @to_date.min.in?([0, 30])
      @to_date = @to_date.advance(minutes: -1).at_end_of_minute
    else
      @to_date = @to_date.at_end_of_hour
    end
    @b_type = Booking.b_types[:hour]
    true
  end

  def hour_date_generator
    @from_date = Time.parse(params[:booking][:from] + ' ' + params[:hour_booking_from]) if
      valid_date?(:from)
    @to_date = Time.parse(params[:booking][:from] + ' ' + params[:hour_booking_to]) if
      valid_date?(:to)
  end

  def valid_date?(type)
    params[:booking][:from].present? && params["hour_booking_#{type}".to_sym].present?
  end

  def day_type_booking
    return false unless params[:booking][:from].present? && params[:booking][:to].present?
    @from_date = Time.parse(params[:booking][:from]).at_beginning_of_day
    @to_date = Time.parse(params[:booking][:to]).at_end_of_day
    @b_type = Booking.b_types[:day]
    true
  end

  def month_type_booking
    return false unless params[:booking][:from].present? && params[:month_quantity].to_i > 0
    @from_date = Time.parse(params[:booking][:from]).at_beginning_of_day
    @to_date = Time.parse(params[:booking][:from])
                .advance(months: params[:month_quantity].to_i)
                .at_end_of_day
    @b_type = Booking.b_types[:month]
    true
  end

  def create_booking
    BookingManager.book(current_user, owner: current_represented,
                                      from: @from_date,
                                      to: @to_date,
                                      space_id: params[:id].to_i,
                                      b_type: @b_type,
                                      quantity: params[:booking][:quantity])
  end
end
