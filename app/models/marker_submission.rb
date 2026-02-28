class MarkerSubmission < ApplicationRecord
  belongs_to :parent_category, class_name: "Category", optional: true
  belongs_to :category, optional: true

  validates :latitude, :longitude, :name, presence: true
end