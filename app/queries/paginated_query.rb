class PaginatedQuery

  def paginate(pagination_params)
    page = pagination_params[:page]
    amount =  pagination_params[:amount]
    page ||= 0
    amount ||= 25
    @relation = @relation.paginate(page: page, per_page: amount)
  end

end
