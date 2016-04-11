require 'rails_helper'
require 'erb'
include ERB::Util

describe SpaceHelper, type: :helper do
  let(:space) { create(:space) }

  describe '#share_on_twitter_url' do
    before do
      allow(I18n).to receive(:t).and_return('hello &!')
    end

    it 'generates the url for sharing on twitter' do
      expect(share_on_twitter_url(space)).to eq('https://twitter.com/intent/tweet' \
        '?text=hello%20%26%21' \
        "&url=http%3A%2F%2Ftest.host%2Fvenues%2F#{space.venue.id}%3Fspace_id%3D#{space.id}")
    end
  end

  describe '#share_on_linkedin_url' do
    it 'generates the url for sharing on linkedin' do
      expect(share_on_linkedin_url(space)).to eq('https://www.linkedin.com/shareArticle' \
        "?url=http%3A%2F%2Ftest.host%2Fvenues%2F#{space.venue.id}%3Fspace_id%3D#{space.id}")
    end
  end

  describe '#share_on_facebook_url' do
    it 'generates the url for sharing on facebook' do
      expect(share_on_facebook_url(space)).to eq('https://www.facebook.com/sharer/sharer.php' \
        "?u=http%3A%2F%2Ftest.host%2Fvenues%2F#{space.venue.id}%3Fspace_id%3D#{space.id}")
    end
  end
end
