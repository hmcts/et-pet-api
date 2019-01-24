class ChangeResponsePdfTemplateReferenceToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :responses, :pdf_template_reference, false
  end
end
