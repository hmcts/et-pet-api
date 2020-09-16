class ConfigureRolePermissionsForRepairClaims < ActiveRecord::Migration[6.0]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
    end
  end

  def up
    Admin::Permission.find_or_create_by!(name: 'repair_claims')
  end

  def down
    # Purposely not reverting this - ever
  end
end
