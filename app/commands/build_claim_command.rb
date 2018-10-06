class BuildClaimCommand < BaseCommand
  def initialize(*)
    super
    self.reference_service = ReferenceService
  end

  def apply(root_object)
    apply_root_attributes(input_data, to: root_object)
    meta.merge! reference: root_object.reference
  end

  private

  attr_accessor :reference_service

  def apply_root_attributes(input_data, to:)
    to.attributes = input_data
  end
end
