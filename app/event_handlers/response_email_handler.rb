class ResponseEmailHandler
  def handle(response)
    send_email(response) if response.email_receipt.present?
  end

  private

  def send_email(response, template_reference: response.email_template_reference)
    office = OfficeService.lookup_by_case_number(response.case_number)
    ResponseMailer.with(response: response, office: office, template_reference: template_reference).confirmation_email.deliver_now
  end
end
