# frozen_string_literal: true

class CreateRespondents < ActiveRecord::Migration[5.1]
  def change
    create_table :respondents do |t|
      t.string :name
      t.references :address, foreign_key: true
      t.string :work_address_telephone_number
      t.string :address_telephone_number
      t.string :acas_number
      t.references :work_address, foreign_key: { to_table: :addresses }
      t.string :alt_phone_number

      t.timestamps
    end
  end
end
