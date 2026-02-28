# app/controllers/places_controller.rb
class PlacesController < ApplicationController
  def autocomplete
    return render json: [] if params[:query].to_s.length < 3

    query = params[:query]

    direct_matches = Place
                       .where("similarity(name, ?) > 0.4", query)

    parent_ids = direct_matches.pluck(:id)

    places = Place
               .includes(parent: :parent)
               .where(id: parent_ids)
               .or(Place.where(parent_id: parent_ids))
               .limit(10)

    render json: places.map { |place|
      {
        name: formatted_name(place),
        lat: place.coordinates&.latitude,
        lng: place.coordinates&.longitude,
        depth: hierarchy_depth(place)
      }
    }
  end

  private

  def formatted_name(place)
    names = []
    current = place

    while current
      names << current.name
      current = current.parent
    end

    names.join(", ")
  end

  def hierarchy_depth(place)
    depth = 0
    current = place
    while current
      depth += 1
      current = current.parent
    end
    depth
  end
end
