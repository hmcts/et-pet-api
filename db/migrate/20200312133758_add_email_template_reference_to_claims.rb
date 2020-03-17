class AddEmailTemplateReferenceToClaims < ActiveRecord::Migration[6.0]
  def change
    add_column :claims, :email_template_reference, :string, null: false, default: 'et1-v1-en'
  end
end
