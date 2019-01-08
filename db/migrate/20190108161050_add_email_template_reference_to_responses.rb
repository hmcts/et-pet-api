class AddEmailTemplateReferenceToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :email_template_reference, :string
  end
end
