require 'rails_helper'

RSpec.describe Message, type: :model do
  # Relations
  it { should belong_to(:booking) }
  it { should belong_to(:user) }
  it { should belong_to(:organization) }

  # Presence
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:m_type) }
end
