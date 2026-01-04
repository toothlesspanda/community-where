class CreateMarkers < ActiveRecord::Migration[8.0]
  def change
    enable_extension "postgis"

    create_table :markers do |t|
      t.string :name
      t.text :description
      t.float :longitude, null: false
      t.float :latitude, null: false
      t.st_point :coordinates, geographic: true

      t.timestamps
    end
  end
end
