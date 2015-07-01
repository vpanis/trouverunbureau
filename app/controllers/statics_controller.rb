class StaticsController < ApplicationController
  def about_us
    render_internationalizated('about_us')
  end

  def our_terms
    render_internationalizated('terms_of_service')
  end

  def how_it_works
    render_internationalizated('how_it_works')
  end

  def faq
    render_internationalizated('faq')
  end

  def contact
    render_internationalizated('contact')
  end

  def terms_of_service
    render_internationalizated('terms_of_service')
  end

  def privacy_policy
    render_internationalizated('privacy_policy')
  end

  private

  def render_internationalizated(static)
    render "statics/#{I18n.locale}/#{static}"
  end
end
