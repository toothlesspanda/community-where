class AddMobilityTranslationColumns < ActiveRecord::Migration[8.1]
  def change
    # Categories
    add_column :categories, :code_translations, :jsonb, default: {}

    # Markers
    add_column :markers, :name_translations, :jsonb, default: {}
    add_column :markers, :description_translations, :jsonb, default: {}

    # Places
    add_column :places, :name_translations, :jsonb, default: {}
  end
end
