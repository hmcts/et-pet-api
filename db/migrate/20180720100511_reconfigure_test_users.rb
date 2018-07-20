class ReconfigureTestUsers < ActiveRecord::Migration[5.2]
  module Admin
    class User < ActiveRecord::Base
      self.table_name = :admin_users
    end
  end

  def up
    Admin::User.find_by(email: 'admin@example.com').tap do |user|
      next if user.nil?
      user.update username: 'admin'
    end
    Admin::User.find_by(email: 'user@example.com').tap do |user|
      next if user.nil?
      user.update username: 'user'
    end
    Admin::User.find_by(email: 'junioruser@example.com').tap do |user|
      next if user.nil?
      user.update username: 'junioruser'
    end
    Admin::User.find_by(email: 'senioruser@example.com').tap do |user|
      next if user.nil?
      user.update username: 'senioruser'
    end
    Admin::User.find_by(email: 'superuser@example.com').tap do |user|
      next if user.nil?
      user.update username: 'superuser'
    end
    Admin::User.find_by(email: 'developer@example.com').tap do |user|
      next if user.nil?
      user.update username: 'developer'
    end
  end

  def down
    # Deliberately doing nothing  - we will never reverse this
  end
end
