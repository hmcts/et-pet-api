# frozen_string_literal: true

module CcdExportable
  extend ActiveSupport::Concern

  included do
    scope :exported_to_ccd_before, lambda { |date_time|
      joins(exports: :external_system).where('external_systems.reference ~ ?', 'ccd').where('exports.updated_at < ? AND exports.state = ?', date_time, 'complete')
    }

    scope :unexported_to_ccd, lambda {
      left_joins(exports: :external_system).
        where('external_systems.id IS NULL OR external_systems.reference ~ ?', 'ccd').
        where('exports.id IS NULL OR exports.state != ?', 'complete')
    }

    scope :exported_or_not_exported_to_atos, lambda {
      left_joins(exports: :external_system).
        where('external_systems.id IS NULL OR external_systems.reference ~ ?', 'atos')
    }
  end
end
