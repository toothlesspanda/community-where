class HomeController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  def index
    @markers = Marker.all.includes(:categories).map do |marker|
      {
        marker: marker,
        categories: marker.categories,
      }
    end
    puts @markers
  end
end
