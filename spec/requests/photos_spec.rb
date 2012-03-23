require 'spec_helper'

describe "Photos" do
  
  context "not signed in" do
    it "needs to be signed in" do
      visit photos_path
      page.body.should have_content "faça login"
    end
  end
  
  
context "signed in" do
  
  
  login_user
  
  describe "GET /photos" do
    it "works! (now write some real specs)" do
      visit photos_path
    end
  end


end 
end
