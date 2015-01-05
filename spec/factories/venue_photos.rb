# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :venue_photo do
		venue { FactoryGirl.build(:venue) }

		photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/dropkick.png')))
	end
end
