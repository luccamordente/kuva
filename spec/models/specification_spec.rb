require 'spec_helper'

describe Specification do
  
  validate_timestamps
  
  describe "relationships" do
    it { should be_embedded_in(:photo) }
    it { should belong_to(:product) }
  end
  
  describe "validations" do
    describe "paper" do
      let!(:order){ Fabricate :order }
      let!(:photo){ order.photos.create }
      
      Specification::PAPERS.each do |paper|
        it "should be valid with #{paper} as paper" do
          specification = photo.create_specification paper: paper
          specification.should be_valid
          specification.errors[:paper].should be_empty
        end
      end
      
      { no: nil, inexisting: :an_inexisting_paper }.each_pair do |which, paper|
        it "should not be valid with #{which} paper" do
          specification = photo.create_specification paper: paper
          specification.should_not be_valid
          specification.errors[:paper].should_not be_empty
        end
      end
    end
    
    
  end
  
  describe "to directory" do
    
    describe "paper" do
      let!(:order){ Fabricate :order }
      let!(:photo){ order.photos.create }
      
      Specification::PAPERS.each do |paper|
        let(:specification){ photo.create_specification paper: paper }
        
        it "knows how to transform #{paper} to directory" do
          specification.paper_to_directory_string.should_not be_nil
          specification.paper_to_directory_string.size.should == 1
        end
      end
    end
    
  end

end
