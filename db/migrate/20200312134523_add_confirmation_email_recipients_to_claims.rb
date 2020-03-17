class AddConfirmationEmailRecipientsToClaims < ActiveRecord::Migration[6.0]
  def change
    add_column :claims, :confirmation_email_recipients, :string, array: true, default: []
  end
end
