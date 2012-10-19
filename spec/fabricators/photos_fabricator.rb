# Read about factories at https://github.com/thoughtbot/factory_girl

Fabricator :photo do
  name "Name"
  count { rand(10) }
  border false
  # specification
  # product
end
