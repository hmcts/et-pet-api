class ClaimRepresentative < ApplicationRecord
  belongs_to :claim
  belongs_to :representative
end
