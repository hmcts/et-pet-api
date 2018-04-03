# frozen_string_literal: true

class ClaimXmlFileValidatorService
  def initialize(files)
    self.files = files
  end

  # @TODO Write correct implementation
  def valid?
    true
  end

  private

  attr_accessor :files
end
