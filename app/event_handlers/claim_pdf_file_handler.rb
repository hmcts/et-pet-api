class ClaimPdfFileHandler
  def handle(claim)
    if claim.pdf_file.blank?
      BuildClaimPdfFileService.new(claim, template_reference: claim.pdf_template_reference).call
      claim.save!
    end
    Rails.application.event_service.publish('ClaimPdfFileAdded', claim)
  end
end
