# encoding: utf-8
include ActionDispatch::TestProcess

case Rails.env
  when 'development'

    class Helper
      TEST_USER = AppConfiguration.for(:test_user).email || 'someone'.freeze
      @@index = 0
      def self.next_email
        email = "#{TEST_USER}+#{@@index}@wolox.com.ar"
        @@index = @@index + 1
        email
      end
    end

    # Users
    puts 'creating users'
    user1 = FactoryGirl.create(:user, first_name: "Robert", last_name: "De Niro", email: Helper.next_email, password: "12341234", phone: "23111131259", gender: 'm', company_name: 'Wolox', interests: 'Lorem ipsum and stuff', profession: Venue::PROFESSIONS.first.to_s, language: 'en', languages_spoken: ['es', 'en'])
    user2 = FactoryGirl.create(:user, first_name: "Al", last_name: "Pacino", email: Helper.next_email, password: "12341234", phone: "65468315358",  gender: 'm', company_name: 'Blue Jeans', interests: 'sarasa zaraza saraza zarasa', profession: Venue::PROFESSIONS.last.to_s)
    user3 = FactoryGirl.create(:user, first_name: "Judie", last_name: "Foster", email: Helper.next_email, password: "12341234", phone: "98461875135",  gender: 'm', company_name: 'i work solo', profession: Venue::PROFESSIONS.first.to_s)
    user4 = FactoryGirl.create(:user, first_name: "John", last_name: "Doe", email: Helper.next_email, password: "12341234", phone: "34155355515",  gender: 'f', company_name: 'freelancer', profession: Venue::PROFESSIONS.first.to_s)
    user5 = FactoryGirl.create(:user, first_name: "Danny", last_name: "Devito", email: Helper.next_email, password: "12341234", phone: "87964522466",  gender: 'm', company_name: 'We are the best', profession: Venue::PROFESSIONS.last.to_s)
    user6 = FactoryGirl.create(:user, first_name: "Julia", last_name: "Robert", email: Helper.next_email, password: "12341234", phone: "65735238463",  gender: 'm', company_name: 'Wololo', profession: Venue::PROFESSIONS.first.to_s)
    user7 = FactoryGirl.create(:user, first_name: "Sean", last_name: "Connery", email: Helper.next_email, password: "12341234", phone: "98976865432",  gender: 'm', company_name: 'Ultimate devs', profession: Venue::PROFESSIONS.last.to_s)
    user8 = FactoryGirl.create(:user, first_name: "Angelina", last_name: "Jolie", email: Helper.next_email, password: "12341234", phone: "65468363365",  gender: 'f', company_name: 'Best Designers', profession: Venue::PROFESSIONS.last.to_s)
    user9 = FactoryGirl.create(:user, first_name: "Carlin", last_name: "Calvo", email: Helper.next_email, password: "12341234", phone: "26654561666",  gender: 'm', company_name: 'Molox', profession: Venue::PROFESSIONS.last.to_s)
    user10 = FactoryGirl.create(:user, first_name: "Quentin", last_name: "Tarantino", email: Helper.next_email, password: "12341234", phone: "6446468684", gender: 'm',  company_name: 'XO7OM', profession: Venue::PROFESSIONS.last.to_s)

    # Organizations
    puts 'creating organizations'
    # user1 owner of org1 and org2
    org1 = Organization.create!(user: user1, name: "The Place", email: Helper.next_email, phone: "32463238825")
    org2 = Organization.create!(user: user1, name: "The Best Place", email: Helper.next_email, phone: "9868768544")

    org3 = Organization.create!(user: user2, name: "Desklirium", email: Helper.next_email, phone: "56822332457")
    org4 = Organization.create!(user: user3, name: "Booking Guru", email: Helper.next_email, phone: "686433135767")

    puts 'creating organization users'
    # user4 works for org1
    OrganizationUser.create!(user: user4, organization: org1, role: OrganizationUser.roles[:admin])
    # user5 is also owner of org2
    OrganizationUser.create!(user: user5, organization: org2, role: OrganizationUser.roles[:owner])
    # user6 works for org2 and org3
    OrganizationUser.create!(user: user6, organization: org2, role: OrganizationUser.roles[:admin])
    OrganizationUser.create!(user: user6, organization: org3, role: OrganizationUser.roles[:admin])
    # user3 works for org1
    OrganizationUser.create!(user: user3, organization: org1, role: OrganizationUser.roles[:admin])


    beginning_of_day = Time.current.at_beginning_of_day
    # puts 'creating countries'
    # country1 = Country.create!(name:"United States")
    # country2 = Country.create!(name:"Canada")
    # country3 = Country.create!(name:"Australia")
    # country4 = Country.create!(name:"Germany")
    # country5 = Country.create!(name:"Andorra")
    # country6 = Country.create!(name:"Austria")
    # country7 = Country.create!(name:"Belgium")
    # country8 = Country.create!(name:"Croatia")
    # country9 = Country.create!(name:"Denmark")
    # country10 = Country.create!(name:"Spain")
    # country11 = Country.create!(name:"Finland")
    # country12 = Country.create!(name:"France")
    # country13 = Country.create!(name:"Greece")
    # country14 = Country.create!(name:"Ireland")
    # country15 = Country.create!(name:"Iceland")
    # country16 = Country.create!(name:"Italy")
    # country17 = Country.create!(name:"Norway")
    # country18 = Country.create!(name:"Sweeden")
    # country19 = Country.create!(name:"Switzerland")
    # country20 = Country.create!(name:"United Kingdom")
    # country21 = Country.create!(name:"Poland")
    # country22 = Country.create!(name:"Portugal")
    # country23 = Country.create!(name:"Netherlands")
    # country24 = Country.create!(name:"Cyprus")
    # country25 = Country.create!(name:"Estonia")
    # country26 = Country.create!(name:"Latvia")
    # country27 = Country.create!(name:"Lithuania")
    # country28 = Country.create!(name:"Luxembourg")
    # country29 = Country.create!(name:"Malta")
    # country30 = Country.create!(name:"Slovakia")
    # country31 = Country.create!(name:"Slovenia")

    # Venues
    puts 'creating venues'
    venue1 = Venue.create!(owner: org1, town: "Buenos Aires", street: "Ayacucho", postal_code: "6541", phone: "68731388", email: Helper.next_email, website: "www.theplaceayacucho.com", latitude: -34.601, longitude: -58.45, name: "The Place Ayacucho", description: Faker::Lorem.paragraph(20), currency: "usd", v_type: Venue.v_types[:corporate_office], space: 400, space_unit: Venue.space_units[:square_mts], floors: 2, rooms: 7, desks: 14, vat_tax_rate: 0, amenities: ["wifi", "cafe_restaurant"], country_code: 'US')
    v1_sp1 = Space.create!(venue: venue1, s_type: Space.s_types[:hot_desk], name: "Personal Desk", capacity: 1, quantity: 8, hour_price: 40, day_price: 250, month_price: 4500, description: Faker::Lorem.paragraph(10))
    v1_sp2 = Space.create!(venue: venue1, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 2, hour_price: 200, day_price: 1500, description: Faker::Lorem.paragraph(10))
    v1_sp3 = Space.create!(venue: venue1, s_type: Space.s_types[:conference_room], name: "Conference Place", capacity: 40, quantity: 1, hour_price: 1000, description: Faker::Lorem.paragraph(10))
    v1_sp4 = Space.create!(venue: venue1, s_type: Space.s_types[:private_office], name: "Blue Office", capacity: 10, quantity: 1, hour_price: 350, day_price: 2400, month_price: 48000, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue1, weekday: 0, from: 800, to: 2000)
    VenueHour.create!(venue: venue1, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue1, weekday: 2, from: 800, to: 2000)
    VenueHour.create!(venue: venue1, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue1, weekday: 4, from: 800, to: 2000)
    venue1.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-1", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue1.status = Venue.statuses[:active]
    venue1.save!

    venue2 = Venue.create!(owner: org2, town: "Buenos Aires", street: "Rivadavia", postal_code: "3121", phone: "571687666", email: Helper.next_email, website: "www.thebestplace.com/buenosaires", latitude: -34.602, longitude: -58.434, name: "The Best Place Buenos Aires", description: Faker::Lorem.paragraph(20), currency: "usd", v_type: Venue.v_types[:business_center], space: 300, space_unit: Venue.space_units[:square_mts], floors: 2, rooms: 4, desks: 14, vat_tax_rate: 0.1, amenities: ["wifi", "cafe_restaurant", "mail_service", "wheelchair_access"], country_code: 'CA')
    v2_sp1 = Space.create!(venue: venue2, s_type: Space.s_types[:hot_desk], name: "Desk", capacity: 1, quantity: 4, hour_price: 38, day_price: 240, month_price: 4200, description: Faker::Lorem.paragraph(10))
    v2_sp2 = Space.create!(venue: venue2, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 7, quantity: 2, hour_price: 185, day_price: 1450, description: Faker::Lorem.paragraph(10))
    v2_sp3 = Space.create!(venue: venue2, s_type: Space.s_types[:private_office], name: "Blue Office", capacity: 12, quantity: 1, hour_price: 400, day_price: 2700, month_price: 50000, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue2, weekday: 0, from: 700, to: 2100)
    VenueHour.create!(venue: venue2, weekday: 1, from: 700, to: 2100)
    VenueHour.create!(venue: venue2, weekday: 2, from: 700, to: 2100)
    VenueHour.create!(venue: venue2, weekday: 3, from: 700, to: 2100)
    VenueHour.create!(venue: venue2, weekday: 4, from: 700, to: 2100)
    VenueHour.create!(venue: venue2, weekday: 5, from: 1000, to: 1800)
    venue2.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-2", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue2.status = Venue.statuses[:active]
    venue2.save!

    venue3 = Venue.create!(owner: org2, town: "Madrid", street: "Malasaña", postal_code: "6511", phone: "66876064", email: Helper.next_email, website: "www.thebestplace.com/madrid", latitude: -34.603, longitude: -58.46, name: "The Best Place Madrid", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:design_studio], space: 800, space_unit: Venue.space_units[:square_mts], floors: 3, rooms: 10, desks: 30, vat_tax_rate: 0.2, amenities: ["wifi", "cafe_restaurant", "mail_service", "wheelchair_access"], country_code: 'AU')
    v3_sp1 = Space.create!(venue: venue3, s_type: Space.s_types[:hot_desk], name: "Desk", capacity: 1, quantity: 25, hour_price: 10, day_price: 25, month_price: 450, description: Faker::Lorem.paragraph(10))
    v3_sp2 = Space.create!(venue: venue3, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 10, quantity: 1, hour_price: 25, description: Faker::Lorem.paragraph(10))
    v3_sp3 = Space.create!(venue: venue3, s_type: Space.s_types[:conference_room], name: "Conference Place", capacity: 100, quantity: 1, hour_price: 170, description: Faker::Lorem.paragraph(10))
    v3_sp4 = Space.create!(venue: venue3, s_type: Space.s_types[:private_office], name: "Blue Office", capacity: 10, quantity: 1, week_price: 1050, month_price: 4200, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue3, weekday: 0, from: 800, to: 2200)
    VenueHour.create!(venue: venue3, weekday: 1, from: 800, to: 2200)
    VenueHour.create!(venue: venue3, weekday: 3, from: 800, to: 2200)
    VenueHour.create!(venue: venue3, weekday: 4, from: 800, to: 2200)
    venue3.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-3", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue3.status = Venue.statuses[:active]
    venue3.save!

    venue4 = Venue.create!(owner: org3, town: "Berlin", street: "Bla strasse", postal_code: "5155", phone: "89040648", email: Helper.next_email, website: "www.desklirium.com", latitude: -34.604, longitude: -58.35, name: "Desklirium", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:design_studio], space: 200, space_unit: Venue.space_units[:square_mts], floors: 1, rooms: 3, desks: 20, vat_tax_rate: 0.1, amenities: ["wifi", "cafe_restaurant"], country_code: 'DE')
    v4_sp1 = Space.create!(venue: venue4, s_type: Space.s_types[:hot_desk], name: "Normal Desk", capacity: 1, quantity: 10, hour_price: 4, day_price: 30, month_price: 600, description: Faker::Lorem.paragraph(10))
    v4_sp2 = Space.create!(venue: venue4, s_type: Space.s_types[:hot_desk], name: "Super Desk", capacity: 1, quantity: 8, hour_price: 5, day_price: 38, month_price: 700, description: Faker::Lorem.paragraph(10))
    v4_sp3 = Space.create!(venue: venue4, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 4, hour_price: 40, description: Faker::Lorem.paragraph(10))
    v4_sp4 = Space.create!(venue: venue4, s_type: Space.s_types[:private_office], name: "Blue Office", capacity: 10, quantity: 1, day_price: 200, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue4, weekday: 0, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 2, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 4, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 5, from: 800, to: 2000)
    VenueHour.create!(venue: venue4, weekday: 6, from: 800, to: 2000)
    venue4.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-4", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue4.status = Venue.statuses[:active]
    venue4.save!

    venue5 = Venue.create!(owner: user6, town: "London", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenue.com", latitude: -34.605, longitude: -58.38, name: "My Place", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:startup_office], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant"], country_code: 'AD')
    v5_sp1 = Space.create!(venue: venue5, s_type: Space.s_types[:hot_desk], name: "Your Desk", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v5_sp2 = Space.create!(venue: venue5, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue5, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue5, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue5, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue5, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue5, weekday: 4, from: 800, to: 1900)
    venue5.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-5", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue5.status = Venue.statuses[:active]
    venue5.save!

    venue6 = Venue.create!(owner: user7, town: "Dublin", street: "Temple str", postal_code: "6166", phone: "516166646", email: Helper.next_email, website: "www.otherdesk.com", latitude: -34.61, longitude: -58.39, name: "The Other Desk", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:startup_office], space: 100, space_unit: Venue.space_units[:square_mts], floors: 1, rooms: 2, desks: 4, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "fax"], country_code: 'AT')
    v6_sp1 = Space.create!(venue: venue6, s_type: Space.s_types[:hot_desk], name: "Home Desk", capacity: 1, quantity: 5, hour_price: 3.5, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue6, weekday: 0, from: 800, to: 1200)
    VenueHour.create!(venue: venue6, weekday: 0, from: 1400, to: 2300)
    VenueHour.create!(venue: venue6, weekday: 1, from: 800, to: 1200)
    VenueHour.create!(venue: venue6, weekday: 1, from: 1400, to: 2300)
    VenueHour.create!(venue: venue6, weekday: 2, from: 800, to: 1200)
    VenueHour.create!(venue: venue6, weekday: 2, from: 1400, to: 2300)
    VenueHour.create!(venue: venue6, weekday: 3, from: 800, to: 1200)
    VenueHour.create!(venue: venue6, weekday: 3, from: 1400, to: 2300)
    VenueHour.create!(venue: venue6, weekday: 4, from: 800, to: 1200)
    VenueHour.create!(venue: venue6, weekday: 4, from: 1400, to: 2300)
    venue6.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-6", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue6.status = Venue.statuses[:active]
    venue6.save!

    venue7 = Venue.create!(owner: user7, town: "Dublin", street: "Temple str", postal_code: "6166", phone: "516166646", email: Helper.next_email, website: "www.otherdesk.com", latitude: -34.62, longitude: -58.41, name: "The Other Desk", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:hotel], space: 100, space_unit: Venue.space_units[:square_mts], floors: 1, rooms: 2, desks: 4, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "mail_service"], country_code: 'BE')
    v7_sp1 = Space.create!(venue: venue7, s_type: Space.s_types[:hot_desk], name: "Home Desk", capacity: 1, quantity: 5, hour_price: 3.5, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue7, weekday: 0, from: 800, to: 1200)
    VenueHour.create!(venue: venue7, weekday: 0, from: 1400, to: 2300)
    VenueHour.create!(venue: venue7, weekday: 1, from: 800, to: 1200)
    VenueHour.create!(venue: venue7, weekday: 1, from: 1400, to: 2300)
    VenueHour.create!(venue: venue7, weekday: 2, from: 800, to: 1200)
    VenueHour.create!(venue: venue7, weekday: 2, from: 1400, to: 2300)
    VenueHour.create!(venue: venue7, weekday: 3, from: 800, to: 1200)
    VenueHour.create!(venue: venue7, weekday: 3, from: 1400, to: 2300)
    VenueHour.create!(venue: venue7, weekday: 4, from: 800, to: 1200)
    VenueHour.create!(venue: venue7, weekday: 4, from: 1400, to: 2300)
    venue7.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-7", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue7.status = Venue.statuses[:active]
    venue7.save!

    venue8 = Venue.create!(owner: user8, town: "London", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenue.com", latitude: -34.56, longitude: -58.498, name: "My Place", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:loft], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'HR')
    v8_sp1 = Space.create!(venue: venue8, s_type: Space.s_types[:hot_desk], name: "Your Desk", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v8_sp2 = Space.create!(venue: venue8, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue8, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue8, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue8, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue8, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue8, weekday: 4, from: 800, to: 1900)
    venue8.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-8", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue8.status = Venue.statuses[:active]
    venue8.save!

    venue9 = Venue.create!(owner: user7, town: "Bohn", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenuebohn.com", latitude: -34.63, longitude: -58.459, name: "Bohn My Place", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:house], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'DK')
    v9_sp1 = Space.create!(venue: venue9, s_type: Space.s_types[:hot_desk], name: "Bohn Your Desk", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v9_sp2 = Space.create!(venue: venue9, s_type: Space.s_types[:meeting_room], name: "Bohn Meeting Place", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue9, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue9, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue9, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue9, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue9, weekday: 4, from: 800, to: 1900)
    venue9.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-9", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue9.status = Venue.statuses[:active]
    venue9.save!

    venue10 = Venue.create!(owner: user9, town: "Oslo", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenueoslo.com", latitude: -34.64, longitude: -58.467, name: "My Place Oslo", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:cafe], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'ES')
    v10_sp1 = Space.create!(venue: venue10, s_type: Space.s_types[:hot_desk], name: "Your Desk Oslo", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v10_sp2 = Space.create!(venue: venue10, s_type: Space.s_types[:meeting_room], name: "Oslo Meeting Place", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue10, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue10, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue10, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue10, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue10, weekday: 4, from: 800, to: 1900)
    venue10.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-10", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue10.status = Venue.statuses[:active]
    venue10.save!

    venue11 = Venue.create!(owner: user7, town: "Estambul", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenueestambul.com", latitude: -34.54, longitude: -58.40, name: "My Place Estambul", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:restaurant], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'FI')
    v11_sp1 = Space.create!(venue: venue11, s_type: Space.s_types[:hot_desk], name: "Your Desk Estambul", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v11_sp2 = Space.create!(venue: venue11, s_type: Space.s_types[:meeting_room], name: "Meeting Place Estambul", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue11, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue11, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue11, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue11, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue11, weekday: 4, from: 800, to: 1900)
    venue11.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-11", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue11.status = Venue.statuses[:active]
    venue11.save!

    venue12 = Venue.create!(owner: user10, town: "Moscu", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenuemoscu.com", latitude: -34.55, longitude: -58.31, name: "Moscu My Place", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:apartment], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'FR')
    v12_sp1 = Space.create!(venue: venue12, s_type: Space.s_types[:hot_desk], name: "Your Desk Moscu", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v12_sp2 = Space.create!(venue: venue12, s_type: Space.s_types[:meeting_room], name: "Meeting Place Moscu", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue12, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue12, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue12, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue12, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue12, weekday: 4, from: 800, to: 1900)
    venue12.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-12", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue12.status = Venue.statuses[:active]
    venue12.save!

    venue13 = Venue.create!(owner: user10, town: "Kabul", street: "Ble street", postal_code: "8911", phone: "998723488", email: Helper.next_email, website: "www.myvenuekabul.com", latitude: -34.609, longitude: -58.41, name: "My Place Kabul", description: Faker::Lorem.paragraph(20), currency: "eur", v_type: Venue.v_types[:coworking_space], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "kitchen", "cafe_restaurant", "security"], country_code: 'GR')
    v13_sp1 = Space.create!(venue: venue13, s_type: Space.s_types[:hot_desk], name: "Good Morning Kabul", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
    v13_sp2 = Space.create!(venue: venue13, s_type: Space.s_types[:meeting_room], name: "Meeting Place Kabul", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))
    VenueHour.create!(venue: venue13, weekday: 0, from: 800, to: 1900)
    VenueHour.create!(venue: venue13, weekday: 1, from: 800, to: 2000)
    VenueHour.create!(venue: venue13, weekday: 2, from: 800, to: 2100)
    VenueHour.create!(venue: venue13, weekday: 3, from: 800, to: 2000)
    VenueHour.create!(venue: venue13, weekday: 4, from: 800, to: 1900)
    venue13.collection_account = BraintreeCollectionAccount.new(merchant_account_id: "0000000000000000-13", force_submit: true, braintree_persisted: true, active: true, status: "active")
    venue13.status = Venue.statuses[:active]
    venue13.save!


    # user1 has access to venue1, venue2 and venue3
    # user2 has access to venue4
    # user3 has access to venue1
    # user4 has access to venue1
    # user5 has access to venue2 and venue3
    # user6 has access to venue4 and venue5
    # user7 has access to venue6, venue7, venue9 and venue11
    # user8 has access to venue8
    # user9 has access to venue10
    # user10 has access to venue12 and venue 13

    # User Favorite Spaces
    puts 'creating user favourites'
    UsersFavorite.create!(user: user1, space: v4_sp1)
    UsersFavorite.create!(user: user1, space: v4_sp2)
    UsersFavorite.create!(user: user1, space: v6_sp1)

    UsersFavorite.create!(user: user2, space: v1_sp1)
    UsersFavorite.create!(user: user2, space: v1_sp2)
    UsersFavorite.create!(user: user2, space: v2_sp1)
    UsersFavorite.create!(user: user2, space: v2_sp2)
    UsersFavorite.create!(user: user2, space: v6_sp1)

    UsersFavorite.create!(user: user3, space: v5_sp1)
    UsersFavorite.create!(user: user3, space: v5_sp2)
    UsersFavorite.create!(user: user3, space: v2_sp1)

    UsersFavorite.create!(user: user4, space: v5_sp1)
    UsersFavorite.create!(user: user4, space: v6_sp1)
    UsersFavorite.create!(user: user4, space: v2_sp1)

    UsersFavorite.create!(user: user5, space: v6_sp1)
    UsersFavorite.create!(user: user5, space: v2_sp1)

    UsersFavorite.create!(user: user6, space: v1_sp1)
    UsersFavorite.create!(user: user6, space: v1_sp2)
    UsersFavorite.create!(user: user6, space: v2_sp1)

    UsersFavorite.create!(user: user7, space: v2_sp1)
    UsersFavorite.create!(user: user7, space: v2_sp2)
    UsersFavorite.create!(user: user7, space: v3_sp1)

    UsersFavorite.create!(user: user8, space: v1_sp1)
    UsersFavorite.create!(user: user8, space: v1_sp2)
    UsersFavorite.create!(user: user8, space: v2_sp1)
    UsersFavorite.create!(user: user8, space: v2_sp2)
    UsersFavorite.create!(user: user8, space: v3_sp1)
    UsersFavorite.create!(user: user8, space: v3_sp2)

    UsersFavorite.create!(user: user9, space: v1_sp3)
    UsersFavorite.create!(user: user9, space: v3_sp3)

    UsersFavorite.create!(user: user10, space: v1_sp4)
    UsersFavorite.create!(user: user10, space: v2_sp3)
    UsersFavorite.create!(user: user10, space: v3_sp4)
    UsersFavorite.create!(user: user10, space: v4_sp4)

    # Valid Venue Hour's Bookings (Next Monday, 10am)
    next_monday = Time.current.next_week(day = :monday).advance(hours: 10)
    next_tuesday = next_monday.advance(days: 1)
    next_wednesday = next_monday.advance(days: 2)
    next_thursday = next_monday.advance(days: 3)
    next_friday = next_monday.advance(days: 4)

    # Bookings
    # v1_sp1-2
    puts 'creating bookings and reviews'
    b_u8_v1_sp1 = Booking.create!(owner: user8, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u8_v1_sp1, stars: 3, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u8_v1_sp1, stars: 5, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user1, space: v1_sp1, state: Booking.states[:denied], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -2), to: next_monday.advance(hours: 10))
    b_u2_v1_sp1_1 = Booking.create!(owner: user2, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -2), to: next_monday.advance(hours: 10))
    ClientReview.create!(booking: b_u2_v1_sp1_1, stars: 5, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u2_v1_sp1_1, stars: 3)

    Booking.create!(owner: user8, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_tuesday.at_beginning_of_day, to: next_tuesday.at_end_of_day)
    b_u2_v1_sp1_2 = Booking.create!(owner: user2, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -2), to: next_tuesday.advance(hours: 10))
    ClientReview.create!(booking: b_u2_v1_sp1_2, stars: 2, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user7, space: v1_sp1, state: Booking.states[:pending_payment], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -2), to: next_tuesday.advance(hours: 10))

    Booking.create!(owner: user8, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_wednesday.at_beginning_of_day, to: next_wednesday.at_end_of_day)
    b_u7_v1_sp1_1 = Booking.create!(owner: user7, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_wednesday.advance(hours: -2), to: next_wednesday.advance(hours: 10))
    ClientReview.create!(booking: b_u7_v1_sp1_1, stars: 3, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: user8, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_thursday.at_beginning_of_day, to: next_thursday.at_end_of_day)
    b_u2_v1_sp1_2 = Booking.create!(owner: user2, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 10))
    ClientReview.create!(booking: b_u2_v1_sp1_2, stars: 2)
    VenueReview.create!(booking: b_u2_v1_sp1_2, stars: 4, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: user8, space: v1_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_friday.at_beginning_of_day, to: next_friday.at_end_of_day)
    Booking.create!(owner: user1, space: v1_sp1, state: Booking.states[:pending_payment], b_type: Booking.b_types[:hour], quantity: 1, from: next_friday.advance(hours: -2), to: next_friday.advance(hours: 10))

    b_u6_v1_sp2_1 = Booking.create!(owner: user6, space: v1_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 2, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u6_v1_sp2_1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u6_v1_sp2_1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u6_v1_sp2_2 = Booking.create!(owner: user6, space: v1_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 2, from: next_tuesday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u6_v1_sp2_2, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u6_v1_sp2_2, stars: 3, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user6, space: v1_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 2, from: next_wednesday.at_beginning_of_day, to: next_wednesday.advance(days: 5).at_end_of_day)
    Booking.create!(owner: user6, space: v1_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 2, from: next_thursday.at_beginning_of_day, to: next_thursday.advance(days: 4).at_end_of_day)
    Booking.create!(owner: user6, space: v1_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 2, from: next_friday.at_beginning_of_day, to: next_friday.advance(days: 3).at_end_of_day)

    # v2_sp1-2
    b_u2_v2_sp1 = Booking.create!(owner: user2, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u2_v2_sp1, stars: 5, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u2_v2_sp1, stars: 3, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user6, space: v2_sp1, state: Booking.states[:denied], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -3), to: next_monday.advance(hours: 11))
    b_u7_v2_sp1_1 = Booking.create!(owner: user7, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -3), to: next_monday.advance(hours: 11))
    ClientReview.create!(booking: b_u7_v2_sp1_1, stars: 5, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u7_v2_sp1_1, stars: 5)

    Booking.create!(owner: user7, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_tuesday.at_beginning_of_day, to: next_tuesday.at_end_of_day)
    b_u2_v2_sp1_2 = Booking.create!(owner: user2, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -3), to: next_tuesday.advance(hours: 11))
    ClientReview.create!(booking: b_u2_v2_sp1_2, stars: 4, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user6, space: v2_sp1, state: Booking.states[:pending_payment], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -3), to: next_tuesday.advance(hours: 11))

    Booking.create!(owner: user2, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_wednesday.at_beginning_of_day, to: next_wednesday.at_end_of_day)
    b_u7_v2_sp1_1 = Booking.create!(owner: user7, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_wednesday.advance(hours: -3), to: next_wednesday.advance(hours: 11))
    ClientReview.create!(booking: b_u7_v2_sp1_1, stars: 2, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: user7, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_thursday.at_beginning_of_day, to: next_thursday.at_end_of_day)
    b_u2_v2_sp1_3 = Booking.create!(owner: user2, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -3), to: next_thursday.advance(hours: 11))
    ClientReview.create!(booking: b_u2_v2_sp1_3, stars: 5)
    VenueReview.create!(booking: b_u2_v2_sp1_3, stars: 2, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: user2, space: v2_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_friday.at_beginning_of_day, to: next_friday.at_end_of_day)
    Booking.create!(owner: user7, space: v2_sp1, state: Booking.states[:pending_payment], b_type: Booking.b_types[:hour], quantity: 1, from: next_friday.advance(hours: -3), to: next_friday.advance(hours: 11))

    b_u6_v2_sp2_1 = Booking.create!(owner: user6, space: v2_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u6_v2_sp2_1, stars: 3, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u6_v2_sp2_1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u6_v2_sp2_2 = Booking.create!(owner: user6, space: v2_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_tuesday.at_beginning_of_day, to: next_tuesday.advance(days: 6).at_end_of_day)
    ClientReview.create!(booking: b_u6_v2_sp2_2, stars: 2, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u6_v2_sp2_2, stars: 3, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user6, space: v2_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_wednesday.at_beginning_of_day, to: next_wednesday.advance(days: 5).at_end_of_day)
    Booking.create!(owner: user6, space: v2_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_thursday.at_beginning_of_day, to: next_thursday.advance(days: 4).at_end_of_day)
    Booking.create!(owner: user6, space: v2_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 1, from: next_friday.at_beginning_of_day, to: next_friday.advance(days: 3).at_end_of_day)

    # v3_sp1-3
    b_u7_v3_sp1 = Booking.create!(owner: user7, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u7_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u7_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u8_v3_sp1 = Booking.create!(owner: user8, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_u8_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u8_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u1_v3_sp1 = Booking.create!(owner: user1, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: 7), to: next_monday.advance(hours: 12), price: 12)
    ClientReview.create!(booking: b_u1_v3_sp1, stars: 2, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u1_v3_sp1, stars: 1, message: Faker::Lorem.paragraph(10))
    b_u2_v3_sp1 = Booking.create!(owner: user2, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -2), to: next_monday.advance(hours: 6))
    ClientReview.create!(booking: b_u2_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u2_v3_sp1, stars: 3, message: Faker::Lorem.paragraph(10))

    b_u7_v3_sp1 = Booking.create!(owner: user7, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_tuesday.at_beginning_of_day, to: next_tuesday.at_end_of_day)
    VenueReview.create!(booking: b_u7_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u8_v3_sp1 = Booking.create!(owner: user8, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_tuesday.at_beginning_of_day, to: next_tuesday.at_end_of_day)
    VenueReview.create!(booking: b_u8_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u1_v3_sp1 = Booking.create!(owner: user1, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: 7), to: next_tuesday.advance(hours: 12))
    VenueReview.create!(booking: b_u1_v3_sp1, stars: 1, message: Faker::Lorem.paragraph(10))
    b_u2_v3_sp1 = Booking.create!(owner: user2, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -2), to: next_tuesday.advance(hours: 6))
    VenueReview.create!(booking: b_u2_v3_sp1, stars: 3, message: Faker::Lorem.paragraph(10))

    b_u7_v3_sp1 = Booking.create!(owner: user7, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_wednesday.at_beginning_of_day, to: next_wednesday.at_end_of_day)
    ClientReview.create!(booking: b_u7_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u8_v3_sp1 = Booking.create!(owner: user8, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_wednesday.at_beginning_of_day, to: next_wednesday.at_end_of_day)
    ClientReview.create!(booking: b_u8_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u1_v3_sp1 = Booking.create!(owner: user1, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_wednesday.advance(hours: 7), to: next_wednesday.advance(hours: 12))
    ClientReview.create!(booking: b_u1_v3_sp1, stars: 2, message: Faker::Lorem.paragraph(10))
    b_u2_v3_sp1 = Booking.create!(owner: user2, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_wednesday.advance(hours: -2), to: next_wednesday.advance(hours: 6))
    ClientReview.create!(booking: b_u2_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))

    b_u7_v3_sp1 = Booking.create!(owner: user7, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_thursday.at_beginning_of_day, to: next_thursday.at_end_of_day)
    ClientReview.create!(booking: b_u7_v3_sp1, stars: 3, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u7_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u8_v3_sp1 = Booking.create!(owner: user8, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 10, from: next_thursday.at_beginning_of_day, to: next_thursday.at_end_of_day)
    ClientReview.create!(booking: b_u8_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u8_v3_sp1, stars: 3, message: Faker::Lorem.paragraph(10))
    b_u1_v3_sp1 = Booking.create!(owner: user1, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: 7), to: next_thursday.advance(hours: 12))
    ClientReview.create!(booking: b_u1_v3_sp1, stars: 3, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u1_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u2_v3_sp1 = Booking.create!(owner: user2, space: v3_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 6))
    ClientReview.create!(booking: b_u2_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u2_v3_sp1, stars: 4, message: Faker::Lorem.paragraph(10))

    b_u9_v3_sp3 = Booking.create!(owner: user9, space: v3_sp3, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 5))
    ClientReview.create!(booking: b_u9_v3_sp3, stars: 1, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u9_v3_sp3, stars: 4, message: Faker::Lorem.paragraph(10))
    b_u9_v3_sp3 = Booking.create!(owner: user9, space: v3_sp3, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 5))
    ClientReview.create!(booking: b_u9_v3_sp3, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u9_v3_sp3, stars: 3, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user9, space: v3_sp3, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 5))
    Booking.create!(owner: user9, space: v3_sp3, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 5))
    Booking.create!(owner: user9, space: v3_sp3, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 5))

    # v4_sp1-2
    b_o1_v4_sp1 = Booking.create!(owner: org1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 9, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_o1_v4_sp1, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_o1_v4_sp1, stars: 5, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user1, space: v4_sp1, state: Booking.states[:denied], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -2), to: next_monday.advance(hours: 10))
    b_u2_v4_sp1_1 = Booking.create!(owner: user2, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_monday.advance(hours: -2), to: next_monday.advance(hours: 10))
    ClientReview.create!(booking: b_u2_v4_sp1_1, stars: 5, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_u2_v4_sp1_1, stars: 4)

    Booking.create!(owner: org1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 9, from: next_tuesday.at_beginning_of_day, to: next_tuesday.at_end_of_day)
    b_u2_v4_sp1_2 = Booking.create!(owner: user2, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -2), to: next_tuesday.advance(hours: 10))
    ClientReview.create!(booking: b_u2_v4_sp1_2, stars: 4, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: user1, space: v4_sp1, state: Booking.states[:already_taken], b_type: Booking.b_types[:hour], quantity: 1, from: next_tuesday.advance(hours: -2), to: next_tuesday.advance(hours: 10))

    Booking.create!(owner: org1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 9, from: next_wednesday.at_beginning_of_day, to: next_wednesday.at_end_of_day)
    b_u1_v4_sp1_1 = Booking.create!(owner: user1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_wednesday.advance(hours: -2), to: next_wednesday.advance(hours: 10))
    ClientReview.create!(booking: b_u1_v4_sp1_1, stars: 3, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: org1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 9, from: next_thursday.at_beginning_of_day, to: next_thursday.at_end_of_day)
    b_u1_v4_sp1_2 = Booking.create!(owner: user1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:hour], quantity: 1, from: next_thursday.advance(hours: -2), to: next_thursday.advance(hours: 10))
    ClientReview.create!(booking: b_u1_v4_sp1_2, stars: 4)
    VenueReview.create!(booking: b_u1_v4_sp1_2, stars: 4, message: Faker::Lorem.paragraph(10))

    Booking.create!(owner: org1, space: v4_sp1, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 9, from: next_friday.at_beginning_of_day, to: next_friday.at_end_of_day)
    Booking.create!(owner: user2, space: v4_sp1, state: Booking.states[:cancelled], b_type: Booking.b_types[:hour], quantity: 1, from: next_friday.advance(hours: -2), to: next_friday.advance(hours: 10))
    Booking.create!(owner: user1, space: v4_sp1, state: Booking.states[:pending_payment], b_type: Booking.b_types[:hour], quantity: 1, from: next_friday.advance(hours: -2), to: next_friday.advance(hours: 10))

    b_o1_v4_sp2_1 = Booking.create!(owner: org1, space: v4_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 3, from: next_monday.at_beginning_of_day, to: next_monday.at_end_of_day)
    ClientReview.create!(booking: b_o1_v4_sp2_1, stars: 1, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_o1_v4_sp2_1, stars: 4, message: Faker::Lorem.paragraph(10))
    b_o1_v4_sp2_2 = Booking.create!(owner: org1, space: v4_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 3, from: next_tuesday.at_beginning_of_day, to: next_tuesday.advance(days: 6).at_end_of_day)
    ClientReview.create!(booking: b_o1_v4_sp2_2, stars: 4, message: Faker::Lorem.paragraph(10))
    VenueReview.create!(booking: b_o1_v4_sp2_2, stars: 3, message: Faker::Lorem.paragraph(10))
    Booking.create!(owner: org1, space: v4_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 3, from: next_wednesday.at_beginning_of_day, to: next_wednesday.advance(days: 5).at_end_of_day)
    Booking.create!(owner: org1, space: v4_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 3, from: next_thursday.at_beginning_of_day, to: next_thursday.advance(days: 4).at_end_of_day)
    Booking.create!(owner: org1, space: v4_sp2, state: Booking.states[:paid], b_type: Booking.b_types[:day], quantity: 3, from: next_friday.at_beginning_of_day, to: next_friday.advance(days: 3).at_end_of_day)
end
