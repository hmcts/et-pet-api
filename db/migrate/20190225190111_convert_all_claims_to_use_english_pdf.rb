class ConvertAllClaimsToUseEnglishPdf < ActiveRecord::Migration[5.2]
  class Claim < ::ActiveRecord::Base
    self.table_name = :claims
  end

  def up
    Claim.update_all pdf_template_reference: 'et1-v1-en'
  end

  def down
    # Do nothing
  end
end
