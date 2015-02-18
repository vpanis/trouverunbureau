class SpaceQuery < PaginatedQuery

  def all(pagination_params, filter_conditions)
    @relation = select_all(filter_conditions)
    paginate(pagination_params)
    @relation
  end

  def select_all(filter_conditions)
    SpaceSearch.new(filter_conditions).find_spaces. includes { [venue, photos] }
                                                    .order('venues.name asc')
  end

end
