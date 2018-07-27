class RemoveTribunalTypeAndIsProcessingOfficeFromOffices < ActiveRecord::Migration[5.2]
  def change
    remove_column :offices, :tribunal_type, :string
    remove_column :offices, :is_processing_office, :boolean
  end
end
