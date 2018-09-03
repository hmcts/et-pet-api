class CopyDisabilityFromRepresentatives < ActiveRecord::Migration[5.2]
  class Response < ActiveRecord::Base
    belongs_to :respondent, class_name: '::CopyDisabilityFromRepresentatives::Respondent'
    belongs_to :representative, optional: true, class_name: '::CopyDisabilityFromRepresentatives::Representative'
  end

  class Representative < ActiveRecord::Base

  end

  class Respondent < ActiveRecord::Base

  end

  def up
    Response.all.each do |response|
      rep = response.representative
      next if rep.nil?
      resp = response.respondent
      resp.update disability: rep.disability, disability_information: rep.disability_information
    end

  end

  def down
    Response.all.each do |response|
      rep = response.representative
      next if rep.nil?
      resp = response.respondent
      rep.update disability: resp.disability, disability_information: resp.disability_information
    end

  end
end
