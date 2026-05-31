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
  Category.find_or_create_by!(code: code, parent: parent).tap do |cat|
    cat.update!(code_translations: translations)
  end
end

# Parent categories
deposit = create_category("deposit")
transportation = create_category("transportation")
sports = create_category("sports")
donations = create_category("donations")
animals = create_category("animals")

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
