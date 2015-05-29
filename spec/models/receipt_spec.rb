require 'rails_helper'

RSpec.describe Receipt, type: :model do
  it { should validate_uniqueness_of(:payment_id) }
end
