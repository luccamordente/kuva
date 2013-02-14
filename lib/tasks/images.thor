# encoding: utf-8`
require 'date'
require './config/environment'


class Images < Thor

  desc "clean", "Limpa imagens com idade maior que 2 semanas"

  def clean
    Order.not_cleaned.older_than(2.weeks).clean_images!
  end

end