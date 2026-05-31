# script/import_places.rb

require "json"

file_path = Rails.root.join("lib/data/freguesias.json")
data = JSON.parse(File.read(file_path))

connection = ActiveRecord::Base.connection

puts "Importing #{data["features"].size} freguesias..."

data["features"].each_with_index do |feature, index|
  props = feature["properties"]
  geometry = feature["geometry"]
  next unless geometry

  district_name     = props["NAME_1"]
  municipality_name = props["NAME_2"]
  parish_name       = props["NAME_3"]

  geojson = geometry.to_json

  # Calcular centroide via PostGIS
  result = connection.execute(<<~SQL)
    SELECT ST_AsText(
      ST_Centroid(
        ST_SetSRID(
          ST_GeomFromGeoJSON('#{geojson}'),
          4326
        )
      )
    ) AS centroid
  SQL

  centroid_wkt = result.first["centroid"]

  district = Place.find_or_create_by!(name: district_name, parent_id: nil).tap do |p|
    p.update!(name_translations: { pt: district_name }) if p.name_translations.blank?
  end

  municipality = Place.find_or_create_by!(
    name: municipality_name,
    parent: district
  ).tap do |p|
    p.update!(name_translations: { pt: municipality_name }) if p.name_translations.blank?
  end

  Place.find_or_create_by!(
    name: parish_name,
    parent: municipality
  ) do |place|
    place.coordinates = centroid_wkt
    place.name_translations = { pt: parish_name }
  end

  puts "Imported #{parish_name}" if index % 100 == 0
end

puts "✅ Import finished!"