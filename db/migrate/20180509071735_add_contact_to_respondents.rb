class AddContactToRespondents < ActiveRecord::Migration[5.2]
  def change
    add_column :respondents, :contact, :string
    add_column :respondents, :dx_number, :string
    add_column :respondents, :contact_preference, :string
    add_column :respondents, :email_address, :string
    add_column :respondents, :fax_number, :string
    add_column :respondents, :organisation_employ_gb, :integer
    add_column :respondents, :organisation_more_than_one_site, :boolean
    add_column :respondents, :employment_at_site_number, :integer
  end
end
