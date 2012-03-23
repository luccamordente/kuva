# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "user#{n}@kuva.com.br"}
    password  "1234567890"
    password_confirmation  "1234567890"
  end
end
