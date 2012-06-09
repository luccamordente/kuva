# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    image { File.open(File.join(Rails.root,"spec/fixtures/rails.png")) }
  end
end
