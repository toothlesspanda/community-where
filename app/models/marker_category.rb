class MarkerCategory < ApplicationRecord
  self.table_name = "markers_categories"

  belongs_to :marker
  belongs_to :category
end
