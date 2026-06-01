CATEGORY_ICONS = {
  # parents
  "deposit" => "fa-solid fa-recycle",
  "transportation" => "fa-solid fa-road",
  "sports" => "fa-solid fa-medal",
  "donations" => "fa-solid fa-hand-holding-heart",
  "animals" => "fa-solid fa-paw",
  # deposit children
  "paper" => "fa-solid fa-newspaper",
  "organic" => "fa-solid fa-leaf",
  "glass" => "fa-solid fa-wine-bottle",
  "plastic" => "fa-solid fa-bottle-water",
  "electronics" => "fa-solid fa-microchip",
  "lamps" => "fa-solid fa-lightbulb",
  "oils" => "fa-solid fa-oil-can",
  "clothes" => "fa-solid fa-shirt",
  # transportation children
  "electric_charge" => "fa-solid fa-charging-station",
  "electric_bikes" => "fa-solid fa-bicycle",
  "bikes_park" => "fa-solid fa-square-parking",
  # sports children
  "futsal_field" => "fa-solid fa-futbol",
  "volleyball_field" => "fa-solid fa-volleyball",
  "skate_park" => "fa-solid fa-person-skating",
  # donations children
  "kids" => "fa-solid fa-child",
  "moms" => "fa-solid fa-person-breastfeeding",
  "food" => "fa-solid fa-utensils",
  "toys" => "fa-solid fa-puzzle-piece",
  # animals children
  "canil" => "fa-solid fa-dog",
  "gatil" => "fa-solid fa-cat",
  "shelter" => "fa-solid fa-paw",
  "hospital" => "fa-solid fa-stethoscope",
  "parks" => "fa-solid fa-tree",
}

CATEGORY_TRANSLATIONS = {
  "deposit" => { pt: "Depósito", en: "Deposit" },
  "transportation" => { pt: "Transportes", en: "Transportation" },
  "sports" => { pt: "Desporto", en: "Sports" },
  "donations" => { pt: "Doações", en: "Donations" },
  "animals" => { pt: "Animais", en: "Animals" },
  # deposit children
  "paper" => { pt: "Papel", en: "Paper" },
  "organic" => { pt: "Orgânico", en: "Organic" },
  "glass" => { pt: "Vidro", en: "Glass" },
  "plastic" => { pt: "Plástico", en: "Plastic" },
  "electronics" => { pt: "Eletrónica", en: "Electronics" },
  "lamps" => { pt: "Lâmpadas", en: "Lamps" },
  "oils" => { pt: "Óleos", en: "Oils" },
  "clothes" => { pt: "Roupa", en: "Clothes" },
  # transportation children
  "electric_charge" => { pt: "Carregamento elétrico", en: "Electric charging" },
  "electric_bikes" => { pt: "Bicicletas elétricas", en: "Electric bikes" },
  "bikes_park" => { pt: "Parque de bicicletas", en: "Bikes park" },
  # sports children
  "futsal_field" => { pt: "Campo de futsal", en: "Futsal field" },
  "volleyball_field" => { pt: "Campo de voleibol", en: "Volleyball field" },
  "skate_park" => { pt: "Skate park", en: "Skate park" },
  # donations children
  "kids" => { pt: "Crianças", en: "Kids" },
  "moms" => { pt: "Mães", en: "Moms" },
  "food" => { pt: "Alimentação", en: "Food" },
  "toys" => { pt: "Brinquedos", en: "Toys" },
  # animals children
  "canil" => { pt: "Canil", en: "Dog shelter" },
  "gatil" => { pt: "Gatil", en: "Cat shelter" },
  "shelter" => { pt: "Abrigo", en: "Shelter" },
  "hospital" => { pt: "Hospital veterinário", en: "Veterinary hospital" },
  "parks" => { pt: "Parques", en: "Parks" }
}

def create_category(code, parent: nil)
  translations = CATEGORY_TRANSLATIONS[code] || { pt: code.humanize, en: code.humanize }
  icon = CATEGORY_ICONS[code]
  Category.find_or_create_by!(code: code, parent: parent).tap do |cat|
    cat.update!(code_translations: translations, icon: icon)
  end
end

CATEGORY_COLORS = {
  "deposit"        => "#4CAF50", # verde — reciclagem
  "transportation" => "#2196F3", # azul — transportes
  "sports"         => "#FF9800", # laranja — desporto/energia
  "donations"      => "#E91E63", # rosa — coração/solidariedade
  "animals"        => "#795548", # castanho — natureza/animais
}

# Parent categories
deposit = create_category("deposit")
transportation = create_category("transportation")
sports = create_category("sports")
donations = create_category("donations")
animals = create_category("animals")

CATEGORY_COLORS.each do |code, color|
  Category.find_by!(code: code).update!(hex_color: color)
end

# Children
%w[paper organic glass plastic electronics lamps oils clothes].each { |c| create_category(c, parent: deposit) }
%w[electric_charge electric_bikes bikes_park].each { |c| create_category(c, parent: transportation) }
%w[futsal_field volleyball_field skate_park].each { |c| create_category(c, parent: sports) }
%w[kids moms food toys].each { |c| create_category(c, parent: donations) }
%w[canil gatil shelter hospital parks].each { |c| create_category(c, parent: animals) }

# Marker submissions for testing (near existing markers)
glass = Category.find_by(code: "glass")
plastic = Category.find_by(code: "plastic")
oils = Category.find_by(code: "oils")
electronics = Category.find_by(code: "electronics")
electric_charge = Category.find_by(code: "electric_charge")

submissions = [
  {
    name: "ecoponto vidro av liberdade",
    description: "ecoponto de vidro na avenida da liberdade, junto ao quiosque",
    latitude: 38.7180, longitude: -9.1420,
    address: "Av. da Liberdade, Lisboa",
    category: glass
  },
  {
    name: "Ponto de recolha de óleo usado",
    description: "Contentor para depositar oleo alimentar usado, no mercado de campo de ourique",
    latitude: 38.7170, longitude: -9.1600,
    address: "Mercado de Campo de Ourique, Lisboa",
    category: oils
  },
  {
    name: "Point 1",
    description: "banco alimentar proximo da praça do comercio",
    latitude: 38.7170, longitude: -9.1392,
    address: "Praça do Comércio, Lisboa",
    category: Category.find_by(code: "food")
  },
  {
    name: "carregador eletrico rossio",
    description: "posto de carregamento para veiculos eletricos junto à praça do rossio",
    latitude: 38.7139, longitude: -9.1395,
    address: "Praça do Rossio, Lisboa",
    category: electric_charge
  },
  {
    name: "Contentor plastico e electronica",
    description: "ponto de recolha de plastico e pequenos electrodomesticos junto ao centro comercial",
    latitude: 38.7300, longitude: -9.1500,
    address: "Centro Comercial, Lisboa",
    category: plastic,
    new_parent_name: nil, new_child_name: nil
  }
]

submissions.each do |s|
  MarkerSubmission.find_or_create_by!(name: s[:name]) do |ms|
    ms.description = s[:description]
    ms.latitude = s[:latitude]
    ms.longitude = s[:longitude]
    ms.address = s[:address]
    ms.category = s[:category]
    ms.parent_category = s[:category]&.parent
    ms.new_parent_name = s[:new_parent_name]
    ms.new_child_name = s[:new_child_name]
  end
end

puts "Created #{MarkerSubmission.count} marker submissions"

# ── Markers ──
markers_data = [
  # Lisboa
  { name: "Ecoponto Vidro - Av. Liberdade", description: "Contentor de vidro junto ao quiosque", address: "Av. da Liberdade, Lisboa", lat: 38.7193, lng: -9.1423, cats: %w[glass] },
  { name: "Ecoponto Papel - Praça do Comércio", description: "Ecoponto azul para papel e cartão", address: "Praça do Comércio, Lisboa", lat: 38.7075, lng: -9.1365, cats: %w[paper] },
  { name: "Contentor de Plástico - Belém", description: "Ecoponto amarelo junto ao Mosteiro dos Jerónimos", address: "Praça do Império, Belém, Lisboa", lat: 38.6979, lng: -9.2068, cats: %w[plastic] },
  { name: "Ponto de Óleo Usado - Mercado da Ribeira", description: "Contentor para depositar óleo alimentar usado", address: "Av. 24 de Julho, Lisboa", lat: 38.7069, lng: -9.1456, cats: %w[oils] },
  { name: "Recolha de Eletrónica - Centro Colombo", description: "Ponto de recolha de pequenos eletrodomésticos", address: "Centro Colombo, Lisboa", lat: 38.7545, lng: -9.1870, cats: %w[electronics] },
  { name: "Contentor de Roupa - Parque das Nações", description: "Contentor de roupa usada junto à estação do Oriente", address: "Gare do Oriente, Lisboa", lat: 38.7679, lng: -9.0990, cats: %w[clothes] },
  { name: "Carregador EV - Saldanha", description: "Posto de carregamento rápido para veículos elétricos", address: "Praça Duque de Saldanha, Lisboa", lat: 38.7351, lng: -9.1453, cats: %w[electric_charge] },
  { name: "Estação GIRA - Cais do Sodré", description: "Estação de bicicletas elétricas partilhadas", address: "Cais do Sodré, Lisboa", lat: 38.7063, lng: -9.1440, cats: %w[electric_bikes] },
  { name: "Parque Bicicletas - Alameda", description: "Parque coberto para bicicletas junto ao metro", address: "Alameda D. Afonso Henriques, Lisboa", lat: 38.7374, lng: -9.1335, cats: %w[bikes_park] },
  { name: "Campo Futsal - Olivais", description: "Campo de futsal público ao ar livre", address: "Parque das Nações, Lisboa", lat: 38.7710, lng: -9.1010, cats: %w[futsal_field] },
  { name: "Skate Park - Ericeira", description: "Skate park municipal junto à praia", address: "Ericeira", lat: 38.9630, lng: -9.4170, cats: %w[skate_park] },
  { name: "Banco Alimentar - Alcântara", description: "Ponto de recolha do Banco Alimentar", address: "Rua de Alcântara, Lisboa", lat: 38.7040, lng: -9.1780, cats: %w[food] },
  { name: "Refood - Graça", description: "Ponto de recolha e distribuição de alimentos", address: "Largo da Graça, Lisboa", lat: 38.7189, lng: -9.1306, cats: %w[food] },
  { name: "Loja Social - Benfica", description: "Doação de roupa, brinquedos e material escolar", address: "Estrada de Benfica, Lisboa", lat: 38.7490, lng: -9.1960, cats: %w[kids toys clothes] },
  { name: "Ecoponto Lâmpadas - Amoreiras", description: "Ponto de recolha de lâmpadas usadas no centro comercial", address: "Amoreiras Shopping, Lisboa", lat: 38.7210, lng: -9.1590, cats: %w[lamps] },
  { name: "Hospital Veterinário - Lisboa", description: "Hospital veterinário com urgência 24h", address: "Av. Almirante Reis, Lisboa", lat: 38.7320, lng: -9.1360, cats: %w[hospital] },

  # Porto
  { name: "Ecoponto Vidro - Ribeira", description: "Contentor de vidro junto ao rio Douro", address: "Cais da Ribeira, Porto", lat: 41.1408, lng: -8.6132, cats: %w[glass] },
  { name: "Ecoponto Papel - Aliados", description: "Ecoponto azul na Avenida dos Aliados", address: "Av. dos Aliados, Porto", lat: 41.1487, lng: -8.6107, cats: %w[paper] },
  { name: "Contentor Plástico - Boavista", description: "Ecoponto amarelo junto à rotunda da Boavista", address: "Praça Mouzinho de Albuquerque, Porto", lat: 41.1581, lng: -8.6310, cats: %w[plastic] },
  { name: "Contentor de Roupa - Campanhã", description: "Contentor de roupa usada junto à estação", address: "Estação de Campanhã, Porto", lat: 41.1488, lng: -8.5856, cats: %w[clothes] },
  { name: "Carregador EV - Casa da Música", description: "Posto de carregamento de veículos elétricos", address: "Av. da Boavista, Porto", lat: 41.1586, lng: -8.6306, cats: %w[electric_charge] },
  { name: "Campo Voleibol - Foz do Douro", description: "Campo de voleibol de praia", address: "Praia do Ourigo, Porto", lat: 41.1500, lng: -8.6780, cats: %w[volleyball_field] },
  { name: "Canil Municipal do Porto", description: "Canil e gatil municipal, adoção de animais", address: "Rua de São Roque, Porto", lat: 41.1650, lng: -8.6050, cats: %w[canil gatil] },
  { name: "Refood - Cedofeita", description: "Recolha e distribuição de excedentes alimentares", address: "Rua de Cedofeita, Porto", lat: 41.1520, lng: -8.6180, cats: %w[food] },
  { name: "Recolha Eletrónica - NorteShopping", description: "Ponto de recolha de eletrónica usada", address: "NorteShopping, Matosinhos", lat: 41.1870, lng: -8.6550, cats: %w[electronics] },

  # Coimbra
  { name: "Ecoponto Vidro - Universidade", description: "Contentor de vidro junto à Universidade de Coimbra", address: "Largo da Porta Férrea, Coimbra", lat: 40.2088, lng: -8.4264, cats: %w[glass] },
  { name: "Ecoponto Orgânico - Mercado D. Pedro V", description: "Contentor para resíduos orgânicos no mercado municipal", address: "Rua Olímpio Nicolau, Coimbra", lat: 40.2110, lng: -8.4310, cats: %w[organic] },
  { name: "Carregador EV - Estação Coimbra-B", description: "Posto de carregamento junto à estação de comboios", address: "Estação Coimbra-B, Coimbra", lat: 40.2225, lng: -8.4390, cats: %w[electric_charge] },
  { name: "Parque Bicicletas - Parque Verde do Mondego", description: "Estacionamento para bicicletas junto ao rio", address: "Parque Verde do Mondego, Coimbra", lat: 40.2050, lng: -8.4310, cats: %w[bikes_park] },

  # Braga
  { name: "Ecoponto Plástico - Bom Jesus", description: "Ecoponto amarelo junto ao Bom Jesus", address: "Bom Jesus, Braga", lat: 41.5549, lng: -8.3776, cats: %w[plastic] },
  { name: "Contentor de Roupa - Centro de Braga", description: "Contentor para doação de roupa usada", address: "Largo do Paço, Braga", lat: 41.5503, lng: -8.4264, cats: %w[clothes] },
  { name: "Abrigo de Animais - Braga", description: "Abrigo municipal para animais abandonados", address: "Braga", lat: 41.5605, lng: -8.4350, cats: %w[shelter] },

  # Faro / Algarve
  { name: "Ecoponto Vidro - Marina de Faro", description: "Contentor de vidro junto à marina", address: "Marina de Faro, Faro", lat: 37.0150, lng: -7.9340, cats: %w[glass] },
  { name: "Contentor Papel - Centro de Faro", description: "Ecoponto azul no centro histórico", address: "Rua de Santo António, Faro", lat: 37.0146, lng: -7.9352, cats: %w[paper] },
  { name: "Carregador EV - Forum Algarve", description: "Posto de carregamento no parque do Forum Algarve", address: "Forum Algarve, Faro", lat: 37.0240, lng: -7.9270, cats: %w[electric_charge] },
  { name: "Parque Canino - Quarteira", description: "Parque cercado para cães", address: "Quarteira, Loulé", lat: 37.0690, lng: -8.1000, cats: %w[parks] },

  # Évora
  { name: "Ecoponto Vidro - Praça do Giraldo", description: "Contentor de vidro no centro histórico", address: "Praça do Giraldo, Évora", lat: 38.5711, lng: -7.9075, cats: %w[glass] },
  { name: "Loja Social - Évora", description: "Doação de roupa e brinquedos para crianças e mães", address: "Évora", lat: 38.5730, lng: -7.9090, cats: %w[kids moms toys] },

  # Aveiro
  { name: "Ecoponto Plástico - Canal Central", description: "Ecoponto amarelo junto aos canais de Aveiro", address: "Canal Central, Aveiro", lat: 40.6405, lng: -8.6538, cats: %w[plastic] },
  { name: "Estação BUGA - Aveiro", description: "Bicicletas gratuitas da cidade de Aveiro", address: "Estação de Aveiro", lat: 40.6430, lng: -8.6440, cats: %w[electric_bikes] },

  # Funchal (Madeira)
  { name: "Ecoponto Vidro - Funchal", description: "Contentor de vidro junto ao mercado dos lavradores", address: "Mercado dos Lavradores, Funchal", lat: 32.6480, lng: -16.9070, cats: %w[glass] },
  { name: "Hospital Veterinário - Funchal", description: "Clínica veterinária com urgência", address: "Funchal, Madeira", lat: 32.6500, lng: -16.9200, cats: %w[hospital] },

  # Setúbal
  { name: "Ecoponto Óleo - Mercado do Livramento", description: "Ponto de recolha de óleos alimentares usados", address: "Mercado do Livramento, Setúbal", lat: 38.5240, lng: -8.8930, cats: %w[oils] },
  { name: "Campo Futsal - Setúbal", description: "Campo de futsal público no parque urbano", address: "Parque Urbano de Albarquel, Setúbal", lat: 38.5190, lng: -8.8840, cats: %w[futsal_field] },

  # Viseu
  { name: "Ecoponto Papel - Rossio de Viseu", description: "Ecoponto azul no centro da cidade", address: "Rossio, Viseu", lat: 40.6610, lng: -7.9120, cats: %w[paper] },
  { name: "Contentor de Roupa - Viseu", description: "Contentor para roupa usada", address: "Av. Emídio Navarro, Viseu", lat: 40.6590, lng: -7.9100, cats: %w[clothes] },
]

markers_data.each do |m|
  marker = Marker.find_or_initialize_by(name: m[:name])
  marker.assign_attributes(
    description: m[:description],
    address: m[:address],
    latitude: m[:lat],
    longitude: m[:lng],
    coordinates: "POINT(#{m[:lng]} #{m[:lat]})"
  )
  marker.save!
  m[:cats].each do |cat_code|
    cat = Category.find_by!(code: cat_code)
    MarkerCategory.find_or_create_by!(marker: marker, category: cat)
  end
end

# Fix any markers missing coordinates
Marker.where(coordinates: nil).find_each do |mk|
  next unless mk.latitude.present? && mk.longitude.present?
  mk.update_column(:coordinates, "POINT(#{mk.longitude} #{mk.latitude})")
end

puts "Created #{Marker.count} markers"
