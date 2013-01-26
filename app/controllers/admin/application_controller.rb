class Admin::ApplicationController < ::ApplicationController
  http_basic_authenticate_with :name => "pedrocinefoto", :password => "bahia"

  layout "admin"

  private

    def enable_auto_refresh
      @auto_refresh = true
    end
end
