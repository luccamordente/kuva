# encoding: utf-8
module UserDecorator

  def first_name
    name.split(/\s/).first
  end

end
