class Response < ApplicationRecord
  belongs_to :respondent
  belongs_to :representative
end
