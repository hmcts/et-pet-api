class AddExternalServiceIdToExports < ActiveRecord::Migration[5.2]
  def change
    add_reference :exports, :external_system, foreign_key: true
  end
end
