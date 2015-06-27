# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

TrymCategory.create(name: 'Gym & Club Memberships', recurring: true, description: 'Fitness Memberships, Golf & Country Club Dues, Social Club Dues, ect.')
TrymCategory.create(name: 'Insurance', recurring: true, description: 'State Farm, Geico, Allstate, Farmers, ect.')
TrymCategory.create(name: 'Home Services & Security', recurring: true, description: 'Landscaping, Security Monitoring Fees, Cleaning Services')
TrymCategory.create(name: 'Newspaper & Magazines', recurring: true, description: "New York Times, Wall Street Journal, Better Homes & Gardens, Reader's Digest, ect.")
TrymCategory.create(name: 'Transportation Services', recurring: true, description: "ZipCar, Public Transport Pass, Car Share, Plug Share")
TrymCategory.create(name: 'Financial Services', recurring: true, description: "Checking Account Maintenance Fees, Credit Card Annual Fees, Credit Reports, Investment Management Fees, ect.")
TrymCategory.create(name: 'Shopping & Home Delivery', recurring: true, description: "Amazon Prime, Costco, Sam's Club, Stitchfix, Bombfell, ect.")
TrymCategory.create(name: 'Online Services', recurring: true, description: 'Subscription Websites, AOL, Match.com, Amazon Web Services, Dropbox, Audible.com, TheLadders.com, ect.')
TrymCategory.create(name: 'Other', recurring: true, description: 'All other recurring expenses')
TrymCategory.create(name: 'TV, Phone, & Internet', recurring: true, description: 'Comcast, Time Warner, Charter, Verizon, AT&T, T-Mobile, Sprint, Hulu, Netflix, HBO, ect.')