class ReconfigureRolePermissionsAgain < ActiveRecord::Migration[5.2]
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
    Admin::Role.find_by!(name: 'Super User').tap do |role|
      permission_names = role.permissions.map(&:name)
      role.permissions << Admin::Permission.find_by(name: 'read_offices') unless permission_names.include?('read_offices')
      role.permissions << Admin::Permission.find_by(name: 'update_offices') unless permission_names.include?('update_offices')
      role.permissions << Admin::Permission.find_by(name: 'delete_offices') unless permission_names.include?('delete_offices')
      role.permissions << Admin::Permission.find_by(name: 'create_offices') unless permission_names.include?('create_offices')
      role.permissions << Admin::Permission.find_by(name: 'read_acas') unless permission_names.include?('read_acas')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_download_logs') unless permission_names.include?('read_acas_download_logs')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_check_digits') unless permission_names.include?('read_acas_check_digits')
      role.permissions << Admin::Permission.find_by(name: 'read_reference_number_generators') unless permission_names.include?('read_reference_number_generators')
      role.permissions << Admin::Permission.find_by(name: 'create_reference_number_generators') unless permission_names.include?('create_reference_number_generators')

      role.permissions << Admin::Permission.find_by(name: 'read_claims') unless permission_names.include?('read_claims')
      role.permissions << Admin::Permission.find_by(name: 'update_claims') unless permission_names.include?('update_claims')
      role.permissions << Admin::Permission.find_by(name: 'delete_claims') unless permission_names.include?('delete_claims')
      role.permissions << Admin::Permission.find_by(name: 'create_claims') unless permission_names.include?('create_claims')

      role.permissions << Admin::Permission.find_by(name: 'read_responses') unless permission_names.include?('read_responses')
      role.permissions << Admin::Permission.find_by(name: 'update_responses') unless permission_names.include?('update_responses')
      role.permissions << Admin::Permission.find_by(name: 'delete_responses') unless permission_names.include?('delete_responses')
      role.permissions << Admin::Permission.find_by(name: 'create_responses') unless permission_names.include?('create_responses')

      role.permissions << Admin::Permission.find_by(name: 'read_users') unless permission_names.include?('read_users')
      role.permissions << Admin::Permission.find_by(name: 'update_users') unless permission_names.include?('update_users')
      role.permissions << Admin::Permission.find_by(name: 'delete_users') unless permission_names.include?('delete_users')
      role.permissions << Admin::Permission.find_by(name: 'create_users') unless permission_names.include?('create_users')
      role.save!
    end

    Admin::Role.find_by!(name: 'Developer').tap do |role|
      permission_names = role.permissions.map(&:name)
      role.permissions << Admin::Permission.find_by(name: 'read_offices') unless permission_names.include?('read_offices')
      role.permissions << Admin::Permission.find_by(name: 'update_offices') unless permission_names.include?('update_offices')
      role.permissions << Admin::Permission.find_by(name: 'delete_offices') unless permission_names.include?('delete_offices')
      role.permissions << Admin::Permission.find_by(name: 'create_offices') unless permission_names.include?('create_offices')

      role.permissions << Admin::Permission.find_by(name: 'read_addresses') unless permission_names.include?('read_addresses')
      role.permissions << Admin::Permission.find_by(name: 'update_addresses') unless permission_names.include?('update_addresses')
      role.permissions << Admin::Permission.find_by(name: 'delete_addresses') unless permission_names.include?('delete_addresses')
      role.permissions << Admin::Permission.find_by(name: 'create_addresses') unless permission_names.include?('create_addresses')

      role.permissions << Admin::Permission.find_by(name: 'read_claims') unless permission_names.include?('read_claims')
      role.permissions << Admin::Permission.find_by(name: 'update_claims') unless permission_names.include?('update_claims')
      role.permissions << Admin::Permission.find_by(name: 'delete_claims') unless permission_names.include?('delete_claims')
      role.permissions << Admin::Permission.find_by(name: 'create_claims') unless permission_names.include?('create_claims')

      role.permissions << Admin::Permission.find_by(name: 'read_responses') unless permission_names.include?('read_responses')
      role.permissions << Admin::Permission.find_by(name: 'update_responses') unless permission_names.include?('update_responses')
      role.permissions << Admin::Permission.find_by(name: 'delete_responses') unless permission_names.include?('delete_responses')
      role.permissions << Admin::Permission.find_by(name: 'create_responses') unless permission_names.include?('create_responses')

      role.permissions << Admin::Permission.find_by(name: 'read_claimants') unless permission_names.include?('read_claimants')
      role.permissions << Admin::Permission.find_by(name: 'update_claimants') unless permission_names.include?('update_claimants')
      role.permissions << Admin::Permission.find_by(name: 'delete_claimants') unless permission_names.include?('delete_claimants')
      role.permissions << Admin::Permission.find_by(name: 'create_claimants') unless permission_names.include?('create_claimants')

      role.permissions << Admin::Permission.find_by(name: 'read_representatives') unless permission_names.include?('read_representatives')
      role.permissions << Admin::Permission.find_by(name: 'update_representatives') unless permission_names.include?('update_representatives')
      role.permissions << Admin::Permission.find_by(name: 'delete_representatives') unless permission_names.include?('delete_representatives')
      role.permissions << Admin::Permission.find_by(name: 'create_representatives') unless permission_names.include?('create_representatives')

      role.permissions << Admin::Permission.find_by(name: 'read_respondents') unless permission_names.include?('read_respondents')
      role.permissions << Admin::Permission.find_by(name: 'update_respondents') unless permission_names.include?('update_respondents')
      role.permissions << Admin::Permission.find_by(name: 'delete_respondents') unless permission_names.include?('delete_respondents')
      role.permissions << Admin::Permission.find_by(name: 'create_respondents') unless permission_names.include?('create_respondents')

      role.permissions << Admin::Permission.find_by(name: 'read_uploaded_files') unless permission_names.include?('read_uploaded_files')
      role.permissions << Admin::Permission.find_by(name: 'update_uploaded_files') unless permission_names.include?('update_uploaded_files')
      role.permissions << Admin::Permission.find_by(name: 'delete_uploaded_files') unless permission_names.include?('delete_uploaded_files')
      role.permissions << Admin::Permission.find_by(name: 'create_uploaded_files') unless permission_names.include?('create_uploaded_files')

      role.permissions << Admin::Permission.find_by(name: 'read_atos_files') unless permission_names.include?('read_atos_files')


      role.permissions << Admin::Permission.find_by(name: 'read_acas') unless permission_names.include?('read_acas')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_download_logs') unless permission_names.include?('read_acas_download_logs')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_check_digits') unless permission_names.include?('read_acas_check_digits')
      role.permissions << Admin::Permission.find_by(name: 'read_jobs') unless permission_names.include?('read_jobs')
      role.permissions << Admin::Permission.find_by(name: 'read_reference_number_generators') unless permission_names.include?('read_reference_number_generators')
      role.permissions << Admin::Permission.find_by(name: 'create_reference_number_generators') unless permission_names.include?('create_reference_number_generators')
      role.save!
    end

    Admin::Role.find_by!(name: 'User').tap do |role|
      permission_names = role.permissions.map(&:name)
      role.permissions << Admin::Permission.find_by(name: 'read_offices') unless permission_names.include?('read_offices')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_download_logs') unless permission_names.include?('read_acas_download_logs')
      role.permissions << Admin::Permission.find_by(name: 'read_acas') unless permission_names.include?('read_acas')
      role.permissions << Admin::Permission.find_by(name: 'read_acas_check_digits') unless permission_names.include?('read_acas_check_digits')
      role.permissions << Admin::Permission.find_by(name: 'read_reference_number_generators') unless permission_names.include?('read_reference_number_generators')
      role.permissions << Admin::Permission.find_by(name: 'create_reference_number_generators') unless permission_names.include?('create_reference_number_generators')
      role.save!
    end
  end

  def down
    # Purposely not reverting this - ever
  end
end
