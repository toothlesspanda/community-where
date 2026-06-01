class AddIconToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :icon, :string
  end
end
