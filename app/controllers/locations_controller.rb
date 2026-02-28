class LocationsController < ApplicationController
  def autocomplete
    results = Geocoder.search(
      "*#{params[:query]}*",
      params: {
        featuretype: "city",
        countrycodes: "pt",
        addressdetails: 0,
        limit: 5
      }
    )

    allowed_types = %w[
      city
      town
      village
      municipality
      county
      state_district
    ]

    filtered = results.select do |r|
      allowed_types.include?(r.data["addresstype"])
    end

    render json: filtered.map { |r|
      {
        name: r.city || r.state || r.address,
        lat: r.latitude,
        lng: r.longitude
      }
    }
  end
end