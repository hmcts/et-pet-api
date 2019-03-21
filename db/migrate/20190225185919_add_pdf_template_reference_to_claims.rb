class AddPdfTemplateReferenceToClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :pdf_template_reference, :string
  end
end
