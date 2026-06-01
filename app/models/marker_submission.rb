class MarkerSubmission < ApplicationRecord
  has_one :proposal, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :latitude, presence: true
  validates :longitude, presence: true
end
