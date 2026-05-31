class AddAddressToMarkersAndSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :markers, :address, :string
    add_column :marker_submissions, :address, :string
  end
end
