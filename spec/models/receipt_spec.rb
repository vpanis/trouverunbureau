require 'rails_helper'

RSpec.describe Receipt, type: :model do
  # Relations
  it { should belong_to(:payment) }

  # Uniqueness
  it { should validate_uniqueness_of(:payment_id).scoped_to(:payment_type) }
end
