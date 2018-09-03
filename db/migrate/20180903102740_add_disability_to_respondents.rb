class AddDisabilityToRespondents < ActiveRecord::Migration[5.2]
  def change
    add_column :respondents, :disability, :boolean
    add_column :respondents, :disability_information, :string
  end
end
