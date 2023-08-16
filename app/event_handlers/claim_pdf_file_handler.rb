class ClaimPdfFileHandler
  def handle(claim)
    if claim.pdf_file.blank?
      # Version 3 of the pdf started to rely on xfdf and xfdf doesnt seem to be backward compatible so just to be sure
      #  we will not use it on anything before version 3.
      use_xfdf = claim.pdf_template_reference.split('-')[1].gsub("v", '').to_i >= 3
      BuildClaimPdfFileService.new(claim, template_reference: claim.pdf_template_reference, time_zone: claim.time_zone, use_xfdf: use_xfdf).call
      claim.save!
    end
    Rails.application.event_service.publish('ClaimPdfFileAdded', claim)
  end
end
