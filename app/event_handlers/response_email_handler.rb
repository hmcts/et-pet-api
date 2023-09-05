class ResponseEmailHandler
  def handle(response)
    send_email(response) unless no_recipient?(response) || sent?(response)
  end

  private

  def no_recipient?(response)
    response.email_receipt.blank?
  end

  def sent?(response)
    response.events.confirmation_email_sent.present?
  end

  def send_email(response, template_reference: response.email_template_reference)
    office = OfficeService.lookup_by_case_number(response.case_number)
    ResponseMailer.with(response: response, office: office, template_reference: template_reference).confirmation_email.deliver_now
    response.events.confirmation_email_sent.create
  end
end
