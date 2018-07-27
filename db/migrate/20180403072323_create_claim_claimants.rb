# frozen_string_literal: true

class CreateClaimClaimants < ActiveRecord::Migration[5.1]
  def change
    create_table :claim_claimants do |t|
      t.references :claim, foreign_key: true
      t.references :claimant, foreign_key: true
    end
  end
end
