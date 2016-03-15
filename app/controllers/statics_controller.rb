class StaticsController < ApplicationController
  def about_us
    render_page 'about_us'
  end

  def our_terms
    render_page 'terms_of_service'
  end

  def how_it_works
    render_page 'how_it_works'
  end

  def faq
    render_page 'faq'
  end

  def terms_of_service
    render_page 'terms_of_service'
  end

  def privacy_policy
    render_page 'privacy_policy'
  end

  private

  def render_page(page)
    meta_tags_for page
    render_internationalizated page
  end

  def meta_tags_for(page)
    set_meta_tags title: t("meta.statics.#{page}.title"),
                  description: t("meta.statics.#{page}.description")
  end

  def render_internationalizated(static)
    render "statics/#{I18n.locale}/#{static}"
  end
end
