module Studio
  class BaseController < ActionController::Base
    layout "studio"

    before_action :authenticate

    private

    def authenticate
      redirect_to studio_login_path unless session[:studio_authenticated]
    end
  end
end
