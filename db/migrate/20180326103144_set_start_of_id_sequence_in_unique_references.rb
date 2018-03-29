class SetStartOfIdSequenceInUniqueReferences < ActiveRecord::Migration[5.1]
  def up
    execute "ALTER SEQUENCE unique_references_id_seq RESTART WITH 20000001;"
  end

  def down

  end
end
