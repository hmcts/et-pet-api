class PopulateOfficeIdInResponses < ActiveRecord::Migration[6.0]
  class Response < ActiveRecord::Base
    self.table_name = :responses
  end
  class Office < ActiveRecord::Base
    self.table_name = :offices
  end
  def up
    Response.find_each do |response|
      office = Office.find_by(code: response.reference[0..1].to_i)
      response.update(office_id: office.id)
    end
  end

  def down
    # Do nothing
  end
end
