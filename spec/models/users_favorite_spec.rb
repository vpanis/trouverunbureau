require 'rails_helper'

RSpec.describe UsersFavorite, type: :model do
  subject { FactoryGirl.create(:users_favorite) }

  # Relations
  it { should belong_to(:user) }
  it { should belong_to(:space) }
end
