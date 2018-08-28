# frozen_string_literal: true

# This service provides assistance to the ClaimXMLImportService and the future ClaimJSONImportService
# It takes a built claim and produces all files required to be attached
#
class ClaimFileBuilderService
  def initialize(claim,
    claim_text_file_builder: ClaimFileBuilder::BuildClaimTextFile,
    claimants_text_file_builder: ClaimFileBuilder::BuildClaimantsTextFile)

    self.claim = claim
    self.claim_text_file_builder = claim_text_file_builder
    self.claimants_text_file_builder = claimants_text_file_builder
  end

  def call
    add_file :claim_text_file, to: claim
    add_file :claimants_text_file, to: claim if claim.multiple_claimants?
  end

  private

  def add_file(builder_type, to:)
    builder = send(:"#{builder_type}_builder")
    builder.call(to)
  end

  attr_accessor :claim, :claim_text_file_builder, :claimants_text_file_builder
end
