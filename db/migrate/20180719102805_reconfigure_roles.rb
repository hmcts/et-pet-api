class ReconfigureRoles < ActiveRecord::Migration[5.2]
  module Admin
    class Role < ActiveRecord::Base
      self.table_name = :admin_roles
    end
  end

  def up
    if Admin::Role.find_by(name: 'junior')
      Admin::Role.find_by(name: 'junior').update(name: 'User')
      Admin::Role.find_by(name: 'senior').update(name: 'Super User')
      Admin::Role.find_by(name: 'administrator').update(name: 'Admin')
      Admin::Role.find_or_create_by(name: 'Developer')
    else
      # Roles do not exist yet potentially
      Admin::Role.find_or_create_by!(name: 'Super User')
      Admin::Role.find_or_create_by!(name: 'User')
      Admin::Role.find_or_create_by!(name: 'Admin', is_admin: true)
      Admin::Role.find_or_create_by!(name: 'Developer')

    end
  end

  def down
    # Purposely not reverting this - ever
  end
end
