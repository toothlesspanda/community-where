class Suggestion < ApplicationRecord
  validates :body, presence: true, length: { maximum: 1024 }
end
