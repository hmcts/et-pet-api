class CreateClaimRepresentatives < ActiveRecord::Migration[5.1]
  def change
    create_table :claim_representatives do |t|
      t.references :claim, foreign_key: true
      t.references :representative, foreign_key: true

      t.timestamps
    end
  end
end
