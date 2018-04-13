# frozen_string_literal: true

class CreateClaimants < ActiveRecord::Migration[5.1]
  def change
    create_table :claimants do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.references :address, foreign_key: true
      t.string :address_telephone_number
      t.string :mobile_number
      t.string :email_address
      t.string :contact_preference
      t.string :gender
      t.date :date_of_birth

      t.timestamps
    end
  end
end
