require 'spec_helper'

describe Image do

  validate_timestamps

  describe "relationships" do
    it { should belong_to(:order)      }
  end

  describe "validations" do
    it "should no be valid without image" do
      image = Fabricate.build :image, image: nil
      image.should_not be_valid
      image.errors[:image].should_not be_nil
    end
  end

  describe "call to magick" do
    let!(:image){ Fabricate :image, image: image_fixture }
    it "should return an RMagick::Image" do
      image.magick.class.should == Magick::Image
    end
  end


  describe "upload" do

    context "of jpeg NON rgb images" do
      let!(:magician){ ImageMagician.new image_fixture 'cmyk.jpg' }

      specify { magician.image_before.should be_formatted_as :jpeg }
      specify { magician.image_before.should have_profile    :cmyk }

      it { magician.image_after.should have_profile :srgb }
      it "keeps the original file" do
        magician.image.original.should be_present
        magician.original_image_after.should have_profile :cmyk
      end
      it "does not set the quality to 92"
      # diz que não precisa ser 100. 92 é extremamente próximo do original
    end

    context "of rgb jpeg image" do
      let!(:magician){ ImageMagician.new image_fixture 'rgb.jpg' }

      specify { magician.image_before.should be_formatted_as :jpeg }
      specify { magician.image_before.should have_profile    :rgb  }

      it { magician.image_after.should have_profile :srgb }
      it { magician.image.original.should be_blank }
      it "does not set the quality to 92"
    end

    context "of rgb NON jpeg image" do
      let!(:magician){ ImageMagician.new image_fixture 'rgb.png' }

      specify { magician.image_before.should be_formatted_as :png }
      specify { magician.image_before.should have_profile    :rgb }

      it { magician.image_after.should be_formatted_as :jpeg }
      it { magician.image.original.should be_blank }
      it "sets the quality to 92"
    end

    context "of NON rgb and NON jpeg image" do
      let!(:magician){ ImageMagician.new image_fixture 'cmyk.tif' }

      specify { magician.image_before.should be_formatted_as :tiff }
      specify { magician.image_before.should have_profile    :cmyk }

      it { magician.image_after.should be_formatted_as :jpeg  }
      it { magician.image_after.should have_profile    :srgb }
      it "keeps the original file" do
        magician.image.original.should be_present
        magician.original_image_after.should have_profile :cmyk
      end
      it "sets the quality to 92"
    end

  end

end
