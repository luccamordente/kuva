class Api::BaseController < ApplicationController

  http_basic_authenticate_with :name => "pedrocinefoto", :password => "kuvaapi"

end