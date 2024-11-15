class SetCcdEnglandAndWalesToUseResponseRemoteOffice < ActiveRecord::Migration[7.1]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems

  end

  def up
    england_and_wales = ExternalSystem.where(reference: 'ccd_england_and_wales_reform').first
    return if england_and_wales.nil?

    england_and_wales.update(response_remote_office: true)
  end

  def down
    england_and_wales = ExternalSystem.where(reference: 'ccd_england_and_wales_reform').first
    return if england_and_wales.nil?

    england_and_wales.update(response_remote_office: false)
  end
end
