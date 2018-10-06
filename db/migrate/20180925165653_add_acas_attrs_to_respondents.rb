class AddAcasAttrsToRespondents < ActiveRecord::Migration[5.2]
  def change
    add_column :respondents, :acas_certificate_number, :string
    add_column :respondents, :acas_exemption_code, :string
  end
end
