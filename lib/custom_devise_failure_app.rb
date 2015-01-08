class CustomDeviseFailureApp < Devise::FailureApp
  
  # Used to know when the sign in error (invalid pass and user) and skip the
  # other devise alerts
  def recall
    flash.now[:message_type] = :invalid
    super
  end
end