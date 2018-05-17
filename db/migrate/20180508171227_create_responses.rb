class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.references :respondent
      t.references :representative
      t.datetime :date_of_receipt
      t.string :reference
      t.string :case_number
      t.string :claimants_name
      t.boolean :agree_with_early_conciliation_details
      t.string :disagree_conciliation_reason
      t.boolean :agree_with_employment_dates
      t.date :employment_start
      t.date :employment_end
      t.string :disagree_employment
      t.boolean :continued_employment
      t.boolean :agree_with_claimants_description_of_job_or_title
      t.string :disagree_claimants_job_or_title
      t.boolean :agree_with_claimants_hours
      t.decimal :queried_hours, precision: 4, scale: 2
      t.boolean :agree_with_earnings_details
      t.decimal :queried_pay_before_tax, precision: 8, scale: 2
      t.string :queried_pay_before_tax_period
      t.decimal :queried_take_home_pay, precision: 8, scale: 2
      t.string :queried_take_home_pay_period
      t.boolean :agree_with_claimant_notice
      t.string :disagree_claimant_notice_reason
      t.boolean :agree_with_claimant_pension_benefits
      t.string :disagree_claimant_pension_benefits_reason
      t.boolean :defend_claim
      t.string :defend_claim_facts

      t.boolean :make_employer_contract_claim
      t.string :claim_information
      t.string :email_receipt



      t.timestamps
    end
  end
end
