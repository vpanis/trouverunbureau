require 'rails_helper'
require 'erb'
include ERB::Util

describe SpaceHelper, type: :helper do
  let(:venue_id) { 99 }

  describe '#share_on_twitter_url' do
    before do
      allow(I18n).to receive(:t).and_return('hello &!')
    end

    it 'generates the url for sharing on twitter' do
      expect(share_on_twitter_url(venue_id)).to eq('https://twitter.com/intent/tweet' \
        '?text=hello%20%26%21' \
        "&url=http%3A%2F%2Ftest.host%2Fvenues%2F#{venue_id}%2Fspaces")
    end
  end

  describe '#share_on_linkedin_url' do
    it 'generates the url for sharing on linkedin' do
      expect(share_on_linkedin_url(venue_id)).to eq('https://www.linkedin.com/shareArticle' \
        "?url=http%3A%2F%2Ftest.host%2Fvenues%2F#{venue_id}%2Fspaces")
    end
  end

  describe '#share_on_facebook_url' do
    it 'generates the url for sharing on facebook' do
      expect(share_on_facebook_url(venue_id)).to eq('https://www.facebook.com/sharer/sharer.php' \
        "?u=http%3A%2F%2Ftest.host%2Fvenues%2F#{venue_id}%2Fspaces")
    end
  end
end
