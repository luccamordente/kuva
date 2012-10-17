# encoding: utf-8
module PhotoDecorator

  def basename
    File.basename self.image.image.current_path if self.image.present? and self.image.image.present?
  end

end
