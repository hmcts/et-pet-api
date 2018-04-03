class CreateRepresentatives < ActiveRecord::Migration[5.1]
  def change
    create_table :representatives do |t|
      t.string :name
      t.string :organisation_name
      t.references :address, foreign_key: true
      t.string :address_telephone_number
      t.string :mobile_number
      t.string :email_address
      t.string :representative_type
      t.string :dx_number

      t.timestamps
    end
  end
end
