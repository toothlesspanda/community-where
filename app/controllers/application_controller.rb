class ApplicationController < ActionController::Base

  helper_method :current_theme
  def current_theme
    party = params[:party].to_s
    %w[xmas halloween].include?(party) ? party : "application"
  end

  def toggle_theme
    @current_theme = @current_theme == "halloween" ? "xmas" : "halloween"

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("theme-toggle", partial: "shared/theme_toggle") }
    end
  end

end
