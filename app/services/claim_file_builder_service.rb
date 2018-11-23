# frozen_string_literal: true
require_relative './claim_file_builder/build_claim_text_file'
require_relative './claim_file_builder/build_claimants_text_file'
# This service takes a built claim and produces all files required to be attached
#
class ClaimFileBuilderService
  def initialize(claim,
    claim_text_file_builder: ::ClaimFileBuilder::BuildClaimTextFile,
    claimants_text_file_builder: ::ClaimFileBuilder::BuildClaimantsTextFile)

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
