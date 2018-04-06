class ClaimExportToLandingService
  def initialize(claim)
    self.claim = claim
  end

  def schedule_export
    schedule_pdf_export
  end

  private

  def schedule_pdf_export
    # At this point in time, we are given the pdf file so all we do is send it on
    # future versions will not do this and the pdf will be generated in this application and sent on
    # @TODO Decide what exporting really is - no need for physical (as in disk based) landing folder
    #
    raise "Boom! not done this yet"
  end

  attr_accessor :claim
end