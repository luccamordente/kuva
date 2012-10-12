RSpec::Matchers.define :have_profile do |expected|
  match do |actual|
    actual.color_profile.to_s.match /#{expected}/i
  end
end

RSpec::Matchers.define :be_formatted_as do |expected|
  match do |actual|
    actual.format.to_s.match /^#{expected}$/i
  end
end