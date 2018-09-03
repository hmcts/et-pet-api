class DropDisabilityFromRepresentatives < ActiveRecord::Migration[5.2]
  def change
    remove_column :representatives, :disability
    remove_column :representatives, :disability_information
  end
end
