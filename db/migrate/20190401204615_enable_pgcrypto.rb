class EnablePgcrypto < ActiveRecord::Migration[5.2]
  def up
    enable_extension 'pgcrypto' unless server_version >= 13.0 || extension_enabled?('pgcrypto')
  end

  def down
    # does nothing
  end

  private

  def server_version
    ActiveRecord::Base.connection.select_value('SELECT version()').split(' ')[1].split('.')[0..1].join('.').to_f
  end
end
