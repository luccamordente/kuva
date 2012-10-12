# Read about factories at https://github.com/thoughtbot/factory_girl

Fabricator :image do
  image { File.open(File.join(Rails.root,"spec/fixtures/images/rails.png")) }
end
