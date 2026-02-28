# script/update_parent_coordinates.rb

connection = ActiveRecord::Base.connection

puts "Updating municipalities..."

# 1️⃣ Municípios (parent of freguesias)
Place.joins(:children)
     .where(children: { parent_id: Place.where(parent_id: nil).pluck(:id) }) # evita distritos aqui

municipalities = Place.where(id: Place.pluck(:parent_id).compact.uniq)

municipalities.each do |municipality|
  next if municipality.coordinates.present?

  result = connection.execute(<<~SQL)
    SELECT ST_AsText(
      ST_Centroid(
        ST_Union(coordinates::geometry)
      )
    ) AS centroid
    FROM places
    WHERE parent_id = #{municipality.id}
  SQL

  centroid = result.first["centroid"]
  next unless centroid

  municipality.update_column(:coordinates, centroid)
end

puts "Updating districts..."

districts = Place.where(parent_id: nil)

districts.each do |district|
  next if district.coordinates.present?

  result = connection.execute(<<~SQL)
    SELECT ST_AsText(
      ST_Centroid(
        ST_Union(coordinates::geometry)
      )
    ) AS centroid
    FROM places
    WHERE parent_id = #{district.id}
  SQL

  centroid = result.first["centroid"]
  next unless centroid

  district.update_column(:coordinates, centroid)
end

puts "✅ Parent coordinates updated!"