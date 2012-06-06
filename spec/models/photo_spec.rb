require 'spec_helper'

describe Photo do
  
  validate_timestamps
  
  describe "relationships" do
    it { should be_embedded_in(:order) }
    it { should embed_one(:spec) }
    it { should belong_to(:product) }
    it { should belong_to(:image) }
  end

end
