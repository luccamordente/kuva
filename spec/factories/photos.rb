# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    name "Name"
    count { rand(10) }
    association :product
    association :spec
  end
end
