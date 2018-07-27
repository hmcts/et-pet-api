class AddContactToRepresentatives < ActiveRecord::Migration[5.2]
  def change
    add_column :representatives, :reference, :string
    add_column :representatives, :contact_preference, :string
    add_column :representatives, :fax_number, :string
    add_column :representatives, :disability, :boolean
    add_column :representatives, :disability_information, :string
  end
end
