class AddDefaultValueToResponsesEmailTemplateReference < ActiveRecord::Migration[7.0]
  def change
    change_column_default :responses, :email_template_reference, "et3-v2-en"
  end
end
