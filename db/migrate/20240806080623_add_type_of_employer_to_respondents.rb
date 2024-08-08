class AddTypeOfEmployerToRespondents < ActiveRecord::Migration[7.1]
  def change
    add_column :respondents, :type_of_employer, :string
  end
end
