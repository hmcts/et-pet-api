class ConfigureRolePermissionsForRoles < ActiveRecord::Migration[5.2]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
      has_many :role_permissions
      has_many :permissions, through: :role_permissions
    end

    class RolePermission < ApplicationRecord
      self.table_name = :admin_role_permissions
      belongs_to :role
      belongs_to :permission
    end

    class Role < ActiveRecord::Base
      self.table_name = :admin_roles
      has_many :role_permissions
      has_many :permissions, through: :role_permissions

      before_save :cache_permissions

      private

      def cache_permissions
        self.permission_names = permissions.map(&:name)
      end
    end
  end

  def up
    Admin::Permission.find_or_create_by!(name: 'create_roles')
    Admin::Permission.find_or_create_by!(name: 'read_roles')
    Admin::Permission.find_or_create_by!(name: 'update_roles')
    Admin::Permission.find_or_create_by!(name: 'delete_roles')

    Admin::Role.find_by!(name: 'Super User').tap do |role|
      permission_names = role.permissions.map(&:name)

      role.permissions << Admin::Permission.find_by(name: 'create_roles') unless permission_names.include?('create_roles')
      role.permissions << Admin::Permission.find_by(name: 'read_roles') unless permission_names.include?('read_roles')
      role.permissions << Admin::Permission.find_by(name: 'update_roles') unless permission_names.include?('update_roles')
      role.permissions << Admin::Permission.find_by(name: 'delete_roles') unless permission_names.include?('delete_roles')

      role.save!
    end

  end

  def down
    # Purposely not reverting this - ever
  end
end
