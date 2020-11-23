class RemoveUnwantedExportsFromAtosSecondary < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      DELETE FROM exports WHERE exports.id IN (
        SELECT DISTINCT exports.id AS id FROM exports
        JOIN events ON events.attached_to_id = exports.resource_id AND events.attached_to_type = exports.resource_type AND events.name = 'ClaimExportedToAtosQueue'
        JOIN external_systems ON exports.external_system_id = external_systems.id
        WHERE external_systems.reference = 'atos_secondary' AND exports.state = 'created' AND exports.percent_complete = 0
      );
    SQL
  end

  def down
    # We cannot undo this - but we don't want anything to fail
  end
end
