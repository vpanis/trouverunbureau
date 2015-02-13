module ParametersHelper

  AMOUNT_DEFAULT = 25
  PAGE_DEFAULT = 1

  def pagination_params
    amount = params[:amount] || AMOUNT_DEFAULT
    page = params[:page] || PAGE_DEFAULT
    { amount: amount, page: page }
  end

  def convert_strings_to_dates(*args)
    args.each do |arg|
      params[arg] = DateTime.parse(params[arg]) if params[arg].present?
    end
  end
end
