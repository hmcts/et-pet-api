class AddDiversityResponsePermissionsForAdmin < ActiveRecord::Migration[5.2]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
    end
  end

  def up
    permissions = [
      :create_diversity_responses, :read_diversity_responses, :update_diversity_responses,
      :delete_diversity_responses, :import_diversity_responses
    ]

    permissions.each do |p|
      Admin::Permission.find_or_create_by! name: p
    end
  end

  def down
    # Deliberately do nothing
  end
end
