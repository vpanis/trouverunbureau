class SpaceQuery

  def all(pagination_params, filter_conditions)
    select_all(filter_conditions).paginate(pagination_params)
  end

  def select_all(filter_conditions)
    SpaceSearch.new(filter_conditions).find_spaces. includes { [venue, photos] }
                                                    .order('venues.name asc')
  end

end
