class PaginatedReviewsQuery < PaginatedQuery

  protected

  def reviews(venue_id, pagination_params)
    @relation = User.where('users.id in (?)', ids).where(status: User.statuses[:active])
                    .order(name: :asc, created_at: :desc)
    paginate(pagination_params)
    @relation
  end
end
