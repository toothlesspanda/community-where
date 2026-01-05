# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


factory = RGeo::Geographic.spherical_factory(srid: 4326)

points = [
  {
    name: "Point 1",
    description: "something about point 1",
    coordinates: factory.point(-9.1390, 38.7169)
  },
  {
    name: "Point 2",
    description: "something about point 2",
    coordinates: factory.point(-9.1605, 38.7302)
  },
  {
    name: "Point 3",
    description: "something about point 3",
    coordinates: factory.point(-9.1267, 38.7075)
  },
  {
    name: "Point 4",
    description: "something about point 4",
    coordinates: factory.point(-9.1500, 38.7223)
  },
  {
    name: "Point 5",
    description: "something about point 5",
    coordinates: factory.point(-9.1458, 38.7401)
  }
]

points.each do |point|
  Marker.create!(
    name: point[:name],
    description: point[:description],
    longitude: point[:coordinates].longitude,
    latitude: point[:coordinates].latitude,
    coordinates: point[:coordinates],
  )
end
