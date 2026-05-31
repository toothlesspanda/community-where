class Place < ApplicationRecord
  extend Mobility

  belongs_to :parent, class_name: "Place", optional: true
  has_many :children, class_name: "Place", foreign_key: :parent_id

  translates :name, column_suffix: "_translations", column_fallback: true

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
