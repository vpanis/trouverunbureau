module SettingsModule
  def settings_person_message?(settings)
    settings['person_message'].present?
  end

  def settings_account_changes?(settings)
    settings['account_changes'].present?
  end

  def settings_accepted_inquiry?(settings)
    settings['accepted_inquiry'].present?
  end

  def settings_incoming_inquiry?(settings)
    settings['incoming_inquiry'].present?
  end

  def default_settings
    { person_message: 'true', account_changes: 'true',
      accepted_inquiry: 'true', incoming_inquiry: 'true' }
  end
end
