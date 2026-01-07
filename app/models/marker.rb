class Marker < ApplicationRecord
  has_many :marker_categories, dependent: :destroy
  has_many :categories, through: :marker_categories
end
