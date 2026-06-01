class AddCategoryIdsToMarkerSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :marker_submissions, :category_ids, :jsonb, default: []

    # Migrate existing data
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE marker_submissions
          SET category_ids = CASE
            WHEN category_id IS NOT NULL THEN jsonb_build_array(category_id)
            ELSE '[]'::jsonb
          END
        SQL
      end
    end
  end
end
