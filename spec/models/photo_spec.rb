require 'spec_helper'

describe Photo do

  validate_timestamps

  describe "relationships" do
    it { should be_embedded_in(:order) }
    it { should embed_one(:specification) }
    it { should belong_to(:product) }
    it { should belong_to(:image) }
  end

  describe "validations" do
    it{ should validate_presence_of(:product) }
  end

  describe "directory" do

    let!(:product){ Fabricate :product, name: "10x15" }
    let!(:order){ Fabricate :order }
    let!(:photo){ order.photos.create count: 5, specification_attributes: { paper: :glossy }, product_id: product.id }

    it "has the correct name" do
      photo.directory.name.should == "P005_10x15_OBNN"
    end


    context "with border" do
      let!(:photo){ order.photos.create count: 5, specification_attributes: { paper: :glossy }, product_id: product.id, border: true }
      it "has the correct name" do
        photo.directory.name.should == "P005_10x15_OBSN"
      end
    end

  end

end
