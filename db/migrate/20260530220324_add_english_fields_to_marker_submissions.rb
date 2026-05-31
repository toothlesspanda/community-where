class AddEnglishFieldsToMarkerSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :marker_submissions, :name_en, :string
    add_column :marker_submissions, :description_en, :string
  end
end
