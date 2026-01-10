class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :code, null: false
      t.references :parent, foreign_key: { to_table: :categories }

      t.timestamps
    end
    add_index :categories, :code, unique: true

    create_table :markers_categories do |t|
      t.references :marker, null: false, foreign_key: true, index: true
      t.references :category, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :markers_categories, [ :marker_id, :category_id ], unique: true
  end
end
