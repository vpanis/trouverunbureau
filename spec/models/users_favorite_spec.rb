require 'rails_helper'

RSpec.describe UsersFavorite, type: :model do
  subject { FactoryGirl.create(:users_favorite) }

  # Relations
  it { should belong_to(:user) }
  it { should belong_to(:space) }

  # Uniquneness
  it { should validate_uniqueness_of(:space).scoped_to(:user_id) }

  # Presence
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:space) }
end
