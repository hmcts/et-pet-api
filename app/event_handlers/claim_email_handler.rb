class ClaimEmailHandler
  def handle(claim)
    send_email(claim) unless has_no_recipients?(claim) || sent?(claim)
  end

  private

  def has_no_recipients?(claim)
    claim.confirmation_email_recipients.empty?
  end

  def sent?(claim)
    claim.events.confirmation_email_sent.present?
  end

  def send_email(claim, template_reference: claim.email_template_reference)
    office = OfficeService.lookup_by_case_number(claim.reference)
    ClaimMailer.with(claim: claim, office: office, template_reference: template_reference).confirmation_email.deliver_now
    claim.events.confirmation_email_sent.create
  end
end
