module Studio
  class SessionsController < ActionController::Base
    layout "studio"

    def new
      redirect_to studio_root_path if session[:studio_authenticated]
    end

    def create
      if params[:username] == ENV["STUDIO_USER"] && params[:password] == ENV["STUDIO_PASSWORD"]
        session[:studio_authenticated] = true
        redirect_to studio_root_path
      else
        flash.now[:alert] = "Invalid credentials."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:studio_authenticated)
      redirect_to studio_login_path
    end
  end
end
