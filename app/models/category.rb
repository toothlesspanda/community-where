class Category < ApplicationRecord
  extend Mobility

  has_many :marker_categories, dependent: :destroy
  has_many :markers, through: :marker_categories

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id

  translates :code, column_suffix: "_translations"

  scope :without_parent, -> { where(parent_id: nil) }
  scope :with_parent, -> { where.not(parent_id: nil) }

  def human_name
    code.to_s.humanize
  end
end
