class Place < ApplicationRecord
  belongs_to :parent, class_name: "Place", optional: true
  has_many :children, class_name: "Place", foreign_key: :parent_id

  def formatted_name(place)
    names = []
    current = place

    while current
      names << current.name
      current = current.parent
    end

    names.join(", ")
  end
end
