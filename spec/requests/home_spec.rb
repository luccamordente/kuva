require 'spec_helper'

describe "Home" do
  
  describe "GET /" do
    before { visit root_path }
    it "has 'start now' button" do
      visit root_path
      click_link "Começar agora"
    end
  end
  
end
