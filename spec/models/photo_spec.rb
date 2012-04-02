require 'spec_helper'

describe Photo do
  
  validate_timestamps
  
  describe "relationships" do
    it { should be_embedded_in(:order) }
    it { should embed_many(:specs) }
  end

end
