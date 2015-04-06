module SelectOptionsHelper

  def countries_options
    Country.all.order(:name).map { |c| [c.name, c.id] }
  end

  def venue_types_options
    Venue.v_types.map { |t| [t("venues.types.#{t.first}"), t.first] }
  end

  def currency_options
    # TODO: define currency list
    [[t('currency.usd.long_name'), 'usd'], [t('currency.gbp.long_name'), 'gbp'],
     [t('currency.euro.long_name'), 'eur'], [t('currency.cad.long_name'), 'cad'],
     [t('currency.aud.long_name'), 'aud']]
  end

  def gender_options
    User::GENDERS.map { |g| [t("users.genders.#{g}"), g.to_s] }
  end

  def profession_options
    Venue::PROFESSIONS.map { |p| [t("venues.professions.#{p}"), p.to_s] }
  end

  def language_options
    # TODO: define languages list
    [[t('languages.es'), 'es'], [t('languages.en'), 'en'], [t('languages.de'), 'de'],
     [t('languages.it'), 'it'], [t('languages.fr'), 'fr'], [t('languages.pt'), 'pt']]
  end

  def space_types_options
    Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.first] }
  end

  def space_types_index_options
    Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.last] }
  end

  def space_types_checkbox_options
    Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.last] }
  end
end
