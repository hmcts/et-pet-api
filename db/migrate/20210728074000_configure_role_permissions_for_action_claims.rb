class ConfigureRolePermissionsForActionClaims < ActiveRecord::Migration[6.1]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
    end
  end

  def up
    Admin::Permission.find_or_create_by!(name: 'action_default_office_claims')
  end

  def down
    # Purposely not reverting this - ever
  end
end
