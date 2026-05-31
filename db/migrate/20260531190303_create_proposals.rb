class CreateProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :proposals do |t|
      t.references :marker_submission, null: false, foreign_key: true
      t.jsonb :proposed_data, null: false, default: {}
      t.string :action, null: false # create, merge, skip
      t.float :confidence
      t.string :status, null: false, default: "pending" # pending, approved, rejected, applied
      t.text :reviewer_notes
      t.timestamps
    end

    add_index :proposals, :status
  end
end
