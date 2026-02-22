class MarkersController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  def index
    markers = Marker.all.includes(:categories)

    if params[:category_ids].present?
      markers = markers
                  .joins(:categories)
                  .where(categories: { id: params[:category_ids] })
                  .distinct
    end

    render json: markers.map { |marker|
      {
        id: marker.id,
        name: marker.name,
        description: marker.description,
        latitude: marker.latitude,
        longitude: marker.longitude,
        categories: marker.categories.flat_map do |category|
          {
            id: category.id,
            code: category.code,
            parent: category.parent.code
          }
        end.uniq
      }
    }
  end
end
