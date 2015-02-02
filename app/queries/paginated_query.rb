class PaginatedQuery

  def paginate(pagination_params)
    page = pagination_params[:page]
    amount =  pagination_params[:amount]
    page ||= 0
    amount ||= 25
    @relation = @relation.page(page).per(amount)
  end

end
