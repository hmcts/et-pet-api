class ReconfigurePermissions < ActiveRecord::Migration[5.2]
  module Admin
    class Permission < ActiveRecord::Base
      self.table_name = :admin_permissions
    end
  end
  def up
    controlled_resources = [:offices, :jobs, :acas, :acas_download_logs,
      :addresses, :atos_files, :claims, :claimants, :exports, :exported_files,
      :representatives, :respondents, :responses, :uploaded_files, :users, :acas_check_digits,
      :reference_number_generators]
    permissions = [:create, :read, :update, :delete, :import].product(controlled_resources).map { |pair| pair.join('_') }.sort

    permissions.each do |p|
      Admin::Permission.find_or_create_by! name: p
    end
  end
end
