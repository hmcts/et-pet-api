class CreateOfficePostCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :office_post_codes do |t|
      t.string :postcode
      t.references :office, foreign_key: true

      t.timestamps
    end
  end
end
