module Kuva
  module Maid

    # field :cleaned_at , type: DateTime

    def clean_images!
      self.images.each(&:remove_image!)
      self.cleaned_at.touch
    end

    def self.clean_images!
      self.all.each(&:clean_images!)
    end

  end
end