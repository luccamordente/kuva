require 'spec_helper'

describe Order do
  
  validate_timestamps
  
  describe "relationships" do
    it { should belong_to(:user) }
    it { should embed_many :photos }
  end
  
end
