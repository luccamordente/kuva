# Read about factories at http://github.com/thoughtbot/factory_girl

Fabricator :user do
  name { Faker::Name.name.gsub /[^a-z\s]/i, '' }
  email { Faker::Internet.email }
  password  "1234567890"
  password_confirmation  "1234567890"
end
