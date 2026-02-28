# script/normalize_places.rb

CONNECTORS = %w[de do da dos das]

def normalize_name(name)
  normalized = name.gsub(/([a-z])([A-Z])/, '\1 \2')

  words = normalized.split
  fixed_words = []

  words.each do |word|
    down = word.downcase

    connector = CONNECTORS.find { |c| down.end_with?(c) && down.length > c.length }

    if connector && words.length > 1
      base = word[0...-connector.length]
      fixed_words << base
      fixed_words << connector
    else
      fixed_words << word
    end
  end

  # Capitalizar corretamente (menos conectores)
  fixed_words.map! do |w|
    CONNECTORS.include?(w.downcase) ? w.downcase : w.capitalize
  end

  fixed_words.join(" ")
end

puts "Normalizing #{Place.count} places..."

Place.find_each do |place|
  new_name = normalize_name(place.name)

  if new_name != place.name
    place.update_column(:name, new_name)
  end
end

puts "✅ Normalization complete!"