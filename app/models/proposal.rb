class Proposal < ApplicationRecord
  belongs_to :marker_submission

  validates :proposed_data, presence: true
  validates :action, presence: true, inclusion: { in: %w[create merge skip] }
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected applied] }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :applied, -> { where(status: "applied") }
end
