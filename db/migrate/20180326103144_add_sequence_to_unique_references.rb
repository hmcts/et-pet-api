class AddSequenceToUniqueReferences < ActiveRecord::Migration[5.1]
  def up
    execute "CREATE SEQUENCE unique_reference_number_seq;"
    execute "ALTER TABLE unique_references ALTER COLUMN number SET DEFAULT nextval('unique_reference_number_seq');"
    execute "ALTER SEQUENCE unique_reference_number_seq OWNED BY unique_references.number;"
  end

  def down

  end
end
