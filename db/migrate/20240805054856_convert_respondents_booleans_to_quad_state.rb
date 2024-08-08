class ConvertRespondentsBooleansToQuadState < ActiveRecord::Migration[7.1]
  def up
    transaction do
      %i[
        disability
      ].each do |column|

        # Change column type
        change_column :respondents, column, :string, null: true
      end
    end
  end

  def down
    transaction do
      %i[
        disability
      ].each do |column|

        # Convert data back to boolean values
        execute <<-SQL.squish
          ALTER TABLE respondents
            ALTER COLUMN #{column} TYPE boolean USING CASE #{column}
              WHEN 'true' THEN true
              WHEN 'false' THEN false
              ELSE NULL
            END
        SQL
      end
    end
  end
end
