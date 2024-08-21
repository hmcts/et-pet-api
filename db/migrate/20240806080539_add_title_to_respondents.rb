class AddTitleToRespondents < ActiveRecord::Migration[7.1]
  def change
    add_column :respondents, :title, :string
  end
end
