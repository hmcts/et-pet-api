class AddCompanyNumberToRespondents < ActiveRecord::Migration[7.1]
  def change
    add_column :respondents, :company_number, :string
  end
end
