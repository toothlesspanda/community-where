class AddCoordinatesIndexToMarkers < ActiveRecord::Migration[8.1]
  def change
    add_index :markers, :coordinates, using: :gist
  end
end
