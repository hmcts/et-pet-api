class AddPrimaryRepresentativeToClaims < ActiveRecord::Migration[5.2]
  def change
    change_table :claims do |t|
      t.belongs_to :primary_representative
    end
  end
end
