class CreateMarkerSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :marker_submissions do |t|
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      t.string :name, null: false
      t.string :description, null: false

      t.references :parent_category, foreign_key: { to_table: :categories }, null: true
      t.references :category, foreign_key: true, null: true
      t.string :new_parent_name
      t.string :new_child_name

      t.timestamps
    end

    add_index :marker_submissions, [:latitude, :longitude]
  end
end