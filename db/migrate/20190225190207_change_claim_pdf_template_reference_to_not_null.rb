class ChangeClaimPdfTemplateReferenceToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :claims, :pdf_template_reference, false
  end
end
