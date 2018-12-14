class ExternalSystem < ApplicationRecord
  has_many :configurations, class_name: 'ExternalSystemConfiguration', dependent: :destroy, inverse_of: false

  scope :containing_office_code, ->(office_code) { where('? = ANY (office_codes)', office_code) }

  def config
    @config ||= configurations.inject({}) do |acc, configuration|
      acc[configuration.key.to_sym] = configuration.value
    end
  end
end
