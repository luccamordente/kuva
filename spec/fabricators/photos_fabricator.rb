# Read about factories at https://github.com/thoughtbot/factory_girl

Fabricator :photo do
  name "Name"
  count { rand(10) }
  product
end
