class ChangeResponseEmailTemplateReferenceToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :responses, :email_template_reference, false
  end
end
