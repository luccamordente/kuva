# Read about factories at http://github.com/thoughtbot/factory_girl

Fabricator :user do
  name { sequence(:name) { |i| "User #{i}" } }
  email { sequence(:email) { |i| "user#{i}@kuva.com" } }
  password  "1234567890"
  password_confirmation  "1234567890"
end
