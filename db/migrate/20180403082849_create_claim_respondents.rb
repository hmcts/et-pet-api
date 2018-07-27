# frozen_string_literal: true

class CreateClaimRespondents < ActiveRecord::Migration[5.1]
  def change
    create_table :claim_respondents do |t|
      t.references :claim, foreign_key: true
      t.references :respondent, foreign_key: true

      t.timestamps
    end
  end
end
