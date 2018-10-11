class AddFaxNumberAndSpecialNeedsToClaimants < ActiveRecord::Migration[5.2]
  def change
    add_column :claimants, :fax_number, :string
    add_column :claimants, :special_needs, :text
  end
end
