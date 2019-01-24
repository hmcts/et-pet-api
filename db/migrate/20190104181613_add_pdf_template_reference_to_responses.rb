class AddPdfTemplateReferenceToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :pdf_template_reference, :string
  end
end
