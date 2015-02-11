class SpaceQuery < PaginatedQuery

  def all(pagination_params)
    @relation = select_all
    paginate(pagination_params)
    @relation
  end

  def select_all
    SpaceSearch.new.find_spaces
  end

end
