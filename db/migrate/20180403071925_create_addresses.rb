# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :building
      t.string :street
      t.string :locality
      t.string :county
      t.string :string
      t.string :post_code

      t.timestamps
    end
  end
end
