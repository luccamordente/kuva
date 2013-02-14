module Kuva::Maid

  module ClassMethods
    def clean_images!
      self.without(:photos).all.each(&:clean_images!)
    end
  end

  module InstanceMethods
    def clean_images!
      self.images.each(&:remove_image!)
      self.cleaned_at = Time.now
      self.save
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods

    receiver.class_eval do
      field :cleaned_at , type: DateTime
      scope :older_than , ->(time) { where :created_at.lt => time.ago }
      scope :cleaned    , ->       { where :cleaned_at.ne => nil      }
      scope :not_cleaned, ->       { where :cleaned_at    => nil      }
    end
  end

end