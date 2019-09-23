class AddStateToExports < ActiveRecord::Migration[6.0]
  def change
    add_column :exports, :state, :string, default: 'created'
  end
end
