# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# encoding: utf-8

# Users
user1 = User.create(first_name: "Robert", last_name: "De Niro", email: "robertdn@example.com", password: "12341234", phone: "23111131259")
user2 = User.create(first_name: "Al", last_name: "Pacino", email: "apacino@example.com", password: "12341234", phone: "65468315358")
user3 = User.create(first_name: "Judie", last_name: "Foster", email: "jfoster@example.com", password: "12341234", phone: "98461875135")
user4 = User.create(first_name: "John", last_name: "Doe", email: "johndoe@example.com", password: "12341234", phone: "34155355515")
user5 = User.create(first_name: "Danny", last_name: "Devito", email: "dannyd@example.com", password: "12341234", phone: "87964522466")
user6 = User.create(first_name: "Julia", last_name: "Robert", email: "juliar@example.com", password: "12341234", phone: "65735238463")
user7 = User.create(first_name: "Sean", last_name: "Connery", email: "sconnery@example.com", password: "12341234", phone: "98976865432")
user8 = User.create(first_name: "Angelina", last_name: "Jolie", email: "ajolie@example.com", password: "12341234", phone: "65468363365")
user9 = User.create(first_name: "Carlin", last_name: "Calvo", email: "el_hacker@example.com", password: "12341234", phone: "26654561666")
user10 = User.create(first_name: "Quentin", last_name: "Tarantino", email: "qtarantino@example.com", password: "12341234", phone: "6446468684")

# Organizations
# user1 owner of org1 and org2
org1 = Organization.create(user: user1, name: "The Place", email: "the_place@example.com", phone: "32463238825")
org2 = Organization.create(user: user1, name: "The Best Place", email: "the_best_place@example.com", phone: "9868768544")

org3 = Organization.create(user: user2, name: "Desklirium", email: "desklirium@example.com", phone: "56822332457")
org4 = Organization.create(user: user3, name: "Booking Guru", email: "bguru@example.com", phone: "686433135767")

# user4 works for org1
OrganizationUser.create(user: user4, organization: org1, role: OrganizationUser.roles[:admin])
# user5 is also owner of org2
OrganizationUser.create(user: user5, organization: org2, role: OrganizationUser.roles[:owner])
# user6 works for org2 and org3
OrganizationUser.create(user: user6, organization: org2, role: OrganizationUser.roles[:admin])
OrganizationUser.create(user: user6, organization: org3, role: OrganizationUser.roles[:admin])
# user3 works for org1
OrganizationUser.create(user: user3, organization: org1, role: OrganizationUser.roles[:admin])

# Venues
venue1 = Venue.create(owner: org1, town: "Buenos Aires", street: "Ayacucho", postal_code: "6541", phone: "68731388", email: "the_place_ayacucho@example.com", website: "www.theplaceayacucho.com", latitude: -30, longitude: -40, name: "The Place Ayacucho", description: Faker::Lorem.paragraph(20), currency: "ars", v_type: Venue.v_types[:corporate_office], space: 400, space_unit: Venue.space_units[:square_mts], floors: 2, rooms: 7, desks: 14, vat_tax_rate: 0, amenities: ["wifi", "meeting_room", "catering_available", "cafe_restaurant"])
v1_sp1 = Space.create(venue: venue1, s_type: Space.s_types[:desk], name: "Personal Desk", capacity: 1, quantity: 8, hour_price: 40, day_price: 250, month_price: 4500, description: Faker::Lorem.paragraph(10))
v1_sp2 = Space.create(venue: venue1, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 2, hour_price: 200, day_price: 1500, description: Faker::Lorem.paragraph(10))
v1_sp3 = Space.create(venue: venue1, s_type: Space.s_types[:conference_room], name: "Conference Place", capacity: 40, quantity: 1, hour_price: 1000, description: Faker::Lorem.paragraph(10))
v1_sp4 = Space.create(venue: venue1, s_type: Space.s_types[:office], name: "Blue Office", capacity: 10, quantity: 1, hour_price: 350, day_price: 2400, month_price: 48000, description: Faker::Lorem.paragraph(10))

venue2 = Venue.create(owner: org2, town: "Buenos Aires", street: "Rivadavia", postal_code: "3121", phone: "571687666", email: "the_best_place1@example.com", website: "www.thebestplace.com/buenosaires", latitude: -30.002, longitude: -40, name: "The Best Place Buenos Aires", description: Faker::Lorem.paragraph(20), currency: "ars", v_type: Venue.v_types[:business_center], space: 300, space_unit: Venue.space_units[:square_mts], floors: 2, rooms: 4, desks: 14, vat_tax_rate: 0.1, amenities: ["wifi", "meeting_room", "catering_available", "cafe_restaurant", "mail_service", "wheelchair_accessible"])
v2_sp1 = Space.create(venue: venue2, s_type: Space.s_types[:desk], name: "Desk", capacity: 1, quantity: 4, hour_price: 38, day_price: 240, month_price: 4200, description: Faker::Lorem.paragraph(10))
v2_sp2 = Space.create(venue: venue2, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 7, quantity: 2, hour_price: 185, day_price: 1450, description: Faker::Lorem.paragraph(10))
v2_sp4 = Space.create(venue: venue2, s_type: Space.s_types[:office], name: "Blue Office", capacity: 12, quantity: 1, hour_price: 400, day_price: 2700, month_price: 50000, description: Faker::Lorem.paragraph(10))

venue3 = Venue.create(owner: org2, town: "Madrid", street: "Malasaña", postal_code: "6511", phone: "66876064", email: "the_best_place2@example.com", website: "www.thebestplace.com/madrid", latitude: 30, longitude: 90, name: "The Best Place Madrid", description: Faker::Lorem.paragraph(20), currency: "euro", v_type: Venue.v_types[:studio], space: 800, space_unit: Venue.space_units[:square_mts], floors: 3, rooms: 10, desks: 30, vat_tax_rate: 0.2, amenities: ["wifi", "meeting_room", "catering_available", "cafe_restaurant", "mail_service", "wheelchair_accessible"])
v3_sp1 = Space.create(venue: venue3, s_type: Space.s_types[:desk], name: "Desk", capacity: 1, quantity: 25, day_price: 25, month_price: 450, description: Faker::Lorem.paragraph(10))
v3_sp2 = Space.create(venue: venue3, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 10, quantity: 1, hour_price: 25, description: Faker::Lorem.paragraph(10))
v3_sp3 = Space.create(venue: venue3, s_type: Space.s_types[:conference_room], name: "Conference Place", capacity: 100, quantity: 1, hour_price: 170, description: Faker::Lorem.paragraph(10))
v3_sp4 = Space.create(venue: venue3, s_type: Space.s_types[:office], name: "Blue Office", capacity: 10, quantity: 1, week_price: 1050, month_price: 4200, description: Faker::Lorem.paragraph(10))

venue4 = Venue.create(owner: org3, town: "Berlin", street: "Bla strasse", postal_code: "5155", phone: "89040648", email: "desklirium@example.com", website: "www.desklirium.com", latitude: 0, longitude: 40, name: "Desklirium", description: Faker::Lorem.paragraph(20), currency: "euro", v_type: Venue.v_types[:studio], space: 200, space_unit: Venue.space_units[:square_mts], floors: 1, rooms: 3, desks: 20, vat_tax_rate: 0.1, amenities: ["wifi", "meeting_room", "catering_available", "cafe_restaurant"])
v4_sp1 = Space.create(venue: venue4, s_type: Space.s_types[:desk], name: "Normal Desk", capacity: 1, quantity: 10, hour_price: 4, day_price: 30, month_price: 600, description: Faker::Lorem.paragraph(10))
v4_sp1 = Space.create(venue: venue4, s_type: Space.s_types[:desk], name: "Super Desk", capacity: 1, quantity: 8, hour_price: 5, day_price: 38, month_price: 700, description: Faker::Lorem.paragraph(10))
v4_sp2 = Space.create(venue: venue4, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 4, hour_price: 40, description: Faker::Lorem.paragraph(10))
v4_sp4 = Space.create(venue: venue4, s_type: Space.s_types[:office], name: "Blue Office", capacity: 10, quantity: 1, day_price: 200, description: Faker::Lorem.paragraph(10))

venue5 = Venue.create(owner: user6, town: "London", street: "Ble street", postal_code: "8911", phone: "998723488", email: "my_venue@example.com", website: "www.myvenue.com", latitude: 60, longitude: 120, name: "My Place", description: Faker::Lorem.paragraph(20), currency: "euro", v_type: Venue.v_types[:startup_office], space: 500, space_unit: Venue.space_units[:square_foots], floors: 2, rooms: 6, desks: 10, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "shared_kitchen", "cafe_restaurant", "lockers"])
v5_sp1 = Space.create(venue: venue5, s_type: Space.s_types[:desk], name: "Your Desk", capacity: 1, quantity: 6, hour_price: 4, description: Faker::Lorem.paragraph(10))
v5_sp2 = Space.create(venue: venue5, s_type: Space.s_types[:meeting_room], name: "Meeting Place", capacity: 5, quantity: 1, hour_price: 15, description: Faker::Lorem.paragraph(10))

venue6 = Venue.create(owner: user7, town: "Dublin", street: "Temple str", postal_code: "6166", phone: "516166646", email: "the_other_desk@example.com", website: "www.otherdesk.com", latitude: -30, longitude: 0, name: "The Other Desk", description: Faker::Lorem.paragraph(20), currency: "euro", v_type: Venue.v_types[:startup_office], space: 100, space_unit: Venue.space_units[:square_mts], floors: 1, rooms: 2, desks: 4, vat_tax_rate: 0, amenities: ["wifi", "pets_allowed", "shared_kitchen", "coffee_tea_filtered_water"])
v6_sp1 = Space.create(venue: venue6, s_type: Space.s_types[:desk], name: "Home Desk", capacity: 1, quantity: 5, hour_price: 3.5, description: Faker::Lorem.paragraph(10))

# user1 has access to venue1, venue2 and venue3
# user2 has access to venue4
# user3 has access to venue1
# user4 has access to venue1
# user5 has access to venue2 and venue3
# user6 has access to venue4 and venue5
# user7 has access to venue6