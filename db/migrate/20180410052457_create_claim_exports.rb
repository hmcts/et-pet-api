class CreateClaimExports < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_exports do |t|
      t.references :claim, foreign_key: true
      t.bigint :pdf_file_id
      t.boolean :in_progress
      t.string :messages, array: true, default: []

      t.timestamps
    end
  end
end
