# encoding: utf-8
require 'date'


class Images < Thor

  desc "clean", "Limpa imagens com idade maior que 2 semanas"

  method_option :environment, :aliases => "-e", :desc => "Sets the app environment"

  def clean
    require './config/environment'
    Order.not_cleaned.older_than(2.weeks).clean_images!
  end

end