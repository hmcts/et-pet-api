class RemoveOldNotStartedCcdExports < ActiveRecord::Migration[6.0]
  class Export < ActiveRecord::Base
    self.table_name = :exports
  end
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
    has_many :exports
  end

  def up
    ExternalSystem.where("reference LIKE 'ccd_%'").each do |system|
      system.exports.where(state: 'created').delete_all
    end
  end
end
