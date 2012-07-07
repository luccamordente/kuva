require 'spec_helper'

describe Specification do
  
  validate_timestamps
  
  describe "relationships" do
    it { should be_embedded_in(:photo) }
    it { should belong_to(:product) }
  end

end
