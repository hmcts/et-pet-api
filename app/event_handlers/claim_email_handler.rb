class ClaimEmailHandler
  def handle(claim)
    send_email(claim) unless claim.confirmation_email_recipients.empty?
  end

  private

  def send_email(claim, template_reference: claim.email_template_reference)
    office = OfficeService.lookup_by_case_number(claim.reference)
    ClaimMailer.with(claim: claim, office: office, template_reference: template_reference).confirmation_email.deliver_now
  end
end
