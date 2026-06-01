class MarkersController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  def index
    return render json: [] unless params[:bbox]
    markers = Marker.all

    west, south, east, north = params[:bbox].split(",")
    markers = markers.where(
      "ST_Intersects(
       coordinates::geometry,
       ST_MakeEnvelope(?, ?, ?, ?, 4326)
     )",
      west, south, east, north
    )


    if params[:category_ids].present?
      markers = markers.where(
        <<~SQL,
          EXISTS (
            SELECT 1
            FROM markers_categories
            WHERE markers_categories.marker_id = markers.id
            AND markers_categories.category_id IN (?)
          )
        SQL
        params[:category_ids]
      )
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
            code: category.code.humanize,
            parent: category.parent.code.humanize,
            color: category.hex_color || category.parent.hex_color,
            icon: category.icon || category.parent.icon
          }
        end.uniq
      }
    }
  end
end
