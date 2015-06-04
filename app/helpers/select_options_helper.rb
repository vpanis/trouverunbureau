module SelectOptionsHelper

  def countries_options
    Venue::SUPPORTED_COUNTRIES.map { |country| [Country.new(country).name, country] }
  end

  def all_countries_options
    Country.all.sort
  end

  def venue_types_options
    Venue.v_types.map { |t| [t("venues.types.#{t.first}"), t.first] }
  end

  def currency_options
    # TODO: define currency list
    Venue::SUPPORTED_CURRENCIES.map { |currency| [t("currency.#{currency}.long_name"), currency] }
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
