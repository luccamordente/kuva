# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'database_cleaner'
 
RSpec.configure do |config|
  config.include Mongoid::Matchers

  config.mock_with :rspec
 
  config.before(:each) do
    DatabaseCleaner.orm = "mongoid" 
    DatabaseCleaner.strategy = :truncation, {:except => %w[ neighborhoods ]}
    DatabaseCleaner.clean
  end
  
  # Devise
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros    , :type => :controller
  
  config.include LoginHelpers, :type => :request
  config.extend LoginMacros, :type => :request
end

def validate_timestamps
  describe "attributes" do
    it { should have_fields(:created_at, :updated_at) }
  end
end

def some_image_path
  File.join(Rails.root,"app/assets/images/rails.png")
end

def image_fixture
  File.new some_image_path
end