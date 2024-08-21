class ConvertResponsesBooleansToQuadState < ActiveRecord::Migration[7.1]
  def up
    transaction do
      %i[
        agree_with_employment_dates
        continued_employment
        agree_with_claimants_description_of_job_or_title
        agree_with_claimants_hours
        agree_with_earnings_details
        agree_with_claimant_notice
        agree_with_claimant_pension_benefits
      ].each do |column|

        # Change column type
        change_column :responses, column, :string, null: true
      end
    end
  end

  def down
    transaction do
      %i[
        agree_with_employment_dates
        continued_employment
        agree_with_claimants_description_of_job_or_title
        agree_with_claimants_hours
        agree_with_earnings_details
        agree_with_claimant_notice
        agree_with_claimant_pension_benefits
      ].each do |column|

        # Convert data back to boolean values
        execute <<-SQL.squish
          ALTER TABLE responses
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
