deposit = Category.find_or_create_by!(code: "deposit")
transportation = Category.find_or_create_by!(code: "transportation")
sports = Category.find_or_create_by!(code: "sports")
donations = Category.find_or_create_by!(code: "donations")
animals = Category.find_or_create_by!(code: "animals")

deposit_categories = %w[paper organic glass plastic electronics lamps oils clothes]

transportation_categories = %w[electric_charge electric_bikes bikes_park]
sports_categories = %w[futsal_field volleyball_field skate_park]
donations_categories = %w[kids moms food toys]
animals_categories = %w[canil gatil shelter hospital parks]

deposit_categories.each { | d| Category.find_or_create_by!(code: d, parent: deposit) }
transportation_categories.each { | d| Category.find_or_create_by!(code: d, parent: transportation) }
sports_categories.each { | d| Category.find_or_create_by!(code: d, parent: sports) }
donations_categories.each { | d| Category.find_or_create_by!(code: d, parent: donations) }
animals_categories.each { | d| Category.find_or_create_by!(code: d, parent: animals) }

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
  marker = Marker.create!(
    name: point[:name],
    description: point[:description],
    longitude: point[:coordinates].longitude,
    latitude: point[:coordinates].latitude,
    coordinates: point[:coordinates],
    )
  category = Category.with_parent.shuffle.first
  MarkerCategory.create!(marker: marker, category: category)
end
