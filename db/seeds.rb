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
