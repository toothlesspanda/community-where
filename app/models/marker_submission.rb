class MarkerSubmission < ApplicationRecord
  has_one :proposal, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :latitude, presence: true
  validates :longitude, presence: true
end
