class Marker < ApplicationRecord
  extend Mobility

  has_many :marker_categories, dependent: :destroy
  has_many :categories, through: :marker_categories

  has_one_attached :photo

  translates :name, :description, column_suffix: "_translations", column_fallback: true
end
