class ExternalSystem < ApplicationRecord
  has_many :configurations, class_name: 'ExternalSystemConfiguration', dependent: :destroy
end
