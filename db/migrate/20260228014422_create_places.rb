class CreatePlaces < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :places do |t|
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :places }, index: true
      t.st_point :coordinates, geographic: true

      t.timestamps
    end

    add_index :places, :coordinates, using: :gist
    add_index :places, :name, using: :gin, opclass: :gin_trgm_ops
  end
end