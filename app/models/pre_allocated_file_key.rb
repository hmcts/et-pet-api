class PreAllocatedFileKey < ApplicationRecord
  belongs_to :allocated_to, polymorphic: true
end
