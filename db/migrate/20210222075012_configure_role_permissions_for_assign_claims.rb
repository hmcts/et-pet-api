class ConfigureRolePermissionsForAssignClaims < ActiveRecord::Migration[6.1]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
    end
  end

  def up
    Admin::Permission.find_or_create_by!(name: 'create_default_office_claims')
    Admin::Permission.find_or_create_by!(name: 'read_default_office_claims')
    Admin::Permission.find_or_create_by!(name: 'delete_default_office_claims')
    Admin::Permission.find_or_create_by!(name: 'assign_default_office_claims')
  end

  def down
    # Purposely not reverting this - ever
  end
end
