class LocaleController < ApplicationController
  def update
    locale = params[:locale].to_s.strip.to_sym
    if I18n.available_locales.include?(locale)
      cookies[:locale] = { value: locale, expires: 1.year.from_now }
    end

    redirect_back fallback_location: root_path
  end
end
