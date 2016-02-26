require 'rails_helper'

RSpec.describe SpaceSerializer, type: :serializer do

  context 'Individual Resource Representation' do

    let(:space) { FactoryGirl.build(:space) }
    let(:serializer) { SpaceSerializer.new(space) }

    subject do
      JSON.parse(serializer.to_json)['space']
    end

    it 'has a name' do
      expect(subject['name']).to eql(space.name)
    end

    it 'has a space_type' do
      expect(subject['space_type']).to eql(I18n.t("spaces.types.#{space.s_type}"))
    end

    pending 'complete the rest of serializer data'
  end
end
