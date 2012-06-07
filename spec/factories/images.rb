# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    image { File.read(File.join(Rails.root,"app/assets/images/rails.png")) }
  end
end
