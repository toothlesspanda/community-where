require "json"

SEEDS_DIR = Rails.root.join("db/seeds")

# ── Categories ──
categories_data = JSON.parse(File.read(SEEDS_DIR.join("categories.json")))

categories_data.each do |parent_data|
  parent = Category.find_or_create_by!(code: parent_data["code"])
  parent.update!(
    code_translations: parent_data["translations"],
    icon: parent_data["icon"],
    hex_color: parent_data["color"]
  )

  parent_data["children"].each do |child_data|
    child = Category.find_or_create_by!(code: child_data["code"], parent: parent)
    child.update!(
      code_translations: child_data["translations"],
      icon: child_data["icon"]
    )
  end
end

puts "#{Category.count} categories"

# ── Markers ──
markers_data = JSON.parse(File.read(SEEDS_DIR.join("markers.json")))

markers_data.each do |m|
  marker = Marker.find_or_initialize_by(name: m["name"])
  marker.assign_attributes(
    description: m["description"],
    address: m["address"],
    latitude: m["lat"],
    longitude: m["lng"],
    coordinates: "POINT(#{m['lng']} #{m['lat']})"
  )
  marker.save!

  m["categories"].each do |cat_code|
    cat = Category.find_by!(code: cat_code)
    MarkerCategory.find_or_create_by!(marker: marker, category: cat)
  end
end

# Fix any markers missing coordinates
Marker.where(coordinates: nil).find_each do |mk|
  next unless mk.latitude.present? && mk.longitude.present?
  mk.update_column(:coordinates, "POINT(#{mk.longitude} #{mk.latitude})")
end

puts "#{Marker.count} markers"

# ── Submissions (test data) ──
submissions_data = JSON.parse(File.read(SEEDS_DIR.join("submissions.json")))

submissions_data.each do |s|
  cat = Category.find_by(code: s["category"])
  MarkerSubmission.find_or_create_by!(name: s["name"]) do |ms|
    ms.description = s["description"]
    ms.latitude = s["latitude"]
    ms.longitude = s["longitude"]
    ms.address = s["address"]
    ms.category_ids = cat ? [cat.id] : []
  end
end

puts "#{MarkerSubmission.count} submissions"
