class Admin::ApplicationController < ::ApplicationController
  http_basic_authenticate_with :name => "pedrocinefoto", :password => "bahia"

  layout "admin"
end
