# frozen_string_literal: true

class CreateClaims < ActiveRecord::Migration[5.1]
  def change
    create_table :claims do |t|
      t.string :reference
      t.string :submission_reference
      t.integer :claimant_count
      t.string :submission_channel
      t.string :case_type
      t.integer :jurisdiction
      t.integer :office_code
      t.datetime :date_of_receipt
      t.boolean :administrator

      t.timestamps
    end
  end
end
