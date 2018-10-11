class AddOtherKnownClaimantNamesToClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :other_known_claimant_names, :string
    add_column :claims, :discrimination_claims, :string, array: true, default: [], null: false
    add_column :claims, :pay_claims, :string, array: true, default: [], null: false
    add_column :claims, :desired_outcomes, :string, array: true, default: [], null: false
    add_column :claims, :other_claim_details, :text, null: true
    add_column :claims, :claim_details, :text, null: true
    add_column :claims, :other_outcome, :string, null: true
    add_column :claims, :send_claim_to_whistleblowing_entity, :boolean, null: true
    add_column :claims, :miscellaneous_information, :text, null: true
    add_column :claims, :employment_details, :jsonb, default: "{}", null: false
    add_column :claims, :is_unfair_dismissal, :boolean, null: true
  end
end
