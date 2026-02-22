class HomeController < ApplicationController
  before_action :set_markers
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  def index
    # @markers = Marker.all.includes(:categories).map do |marker|
    #   {
    #     marker: marker,
    #     categories: marker.categories,
    #   }
    # end
    @parent_categories = Category.where(parent_id: nil).includes(:children)
  end

  def filter_map_view
    @markers = Marker.all.includes(:categories)
  end

  private
  def set_markers
    @markers = Marker.all.includes(:categories)
  end
end
