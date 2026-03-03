class MarkerSubmission < ApplicationRecord
  belongs_to :parent_category, class_name: "Category", optional: true
  belongs_to :category, optional: true

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :latitude, presence: true
  validates :longitude, presence: true
end
