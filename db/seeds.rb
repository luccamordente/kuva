# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create name: "Developer", email: "developer@kuva.local", password: "1234567890", password_confirmation: "1234567890"
Fabricate :product, dimensions: [15, 10]
Fabricate :product, dimensions: [21, 15]
Fabricate :product, dimensions: [25, 20]
Fabricate :product, dimensions: [30, 20]
Fabricate :product, dimensions: [30, 24]
Fabricate :product, dimensions: [40, 30]