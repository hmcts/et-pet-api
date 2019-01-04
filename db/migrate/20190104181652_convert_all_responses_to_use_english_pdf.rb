class ConvertAllResponsesToUseEnglishPdf < ActiveRecord::Migration[5.2]
  class Response < ::ActiveRecord::Base
    self.table_name = :responses
  end

  def up
    Response.update_all pdf_template_reference: 'et3-v1-en'
  end

  def down
    # Do nothing
  end
end
