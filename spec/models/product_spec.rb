require 'spec_helper'

describe Product do

  describe "validations" do
    validate_timestamps
    it{ should validate_presence_of :price           }
    it{ should validate_presence_of :name            }
    it{ should validate_presence_of :dimensions      }
    it{ should validate_numericality_of :price       }
  end

  describe "relationships" do
    # it { should have_many(:photos) }
  end


  describe "sorted dimensions" do
    let(:product){ Fabricate :product, dimensions: [15, 10] }
    it "should sort product dimensions when saved" do
      product.dimensions.should == [10, 15]
    end
  end


  describe "easy dimensions" do
    let(:product){ Fabricate :product, dimension1: 15, dimension2: 10 }
    it "should sort product dimensions when saved" do
      product.dimensions.should == [10, 15]
    end
    it "should generate the product name" do
      product.name.should == "10x15"
    end
  end


end
