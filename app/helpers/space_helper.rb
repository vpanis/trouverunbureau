module SpaceHelper
  def share_on_twitter_url(venue_id)
    'https://twitter.com/intent/tweet' \
      "?text=#{url_encode(I18n.t('spaces.share_text'))}" \
      "&url=#{url_encode(spaces_venue_url(venue_id))}"
  end

  def share_on_linkedin_url(venue_id)
    'https://www.linkedin.com/shareArticle' \
      "?url=#{url_encode(spaces_venue_url(venue_id))}"
  end

  def share_on_facebook_url(venue_id)
    'https://www.facebook.com/sharer/sharer.php' \
      "?u=#{url_encode(spaces_venue_url(venue_id))}"
  end
end
