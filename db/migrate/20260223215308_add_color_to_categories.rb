class AddColorToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :hex_color, :string
  end
end
