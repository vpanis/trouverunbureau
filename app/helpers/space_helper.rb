module SpaceHelper
  def share_on_twitter_url(space)
    'https://twitter.com/intent/tweet' \
      "?text=#{url_encode(I18n.t('spaces.share_text', space_type: I18n.t("spaces.types.#{space.s_type}").downcase))}" \
      "&url=#{space_venue_url(space)}"
  end

  def share_on_linkedin_url(space)
    'https://www.linkedin.com/shareArticle' \
      "?url=#{space_venue_url(space)}"
  end

  def share_on_facebook_url(space)
    'https://www.facebook.com/sharer/sharer.php' \
      "?u=#{space_venue_url(space)}"
  end

  private

  def space_venue_url(space)
    url_encode(venue_url(space.venue.id, space_id: space.id))
  end
end
