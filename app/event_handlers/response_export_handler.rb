class ResponseExportHandler
  def handle(response)
    Export.responses.create resource: response
    response.save
    send_email(response) if response.email_receipt.present?
  end

  private

  def send_email(response)
    office = OfficeService.lookup_by_case_number(response.case_number)
    ResponseMailer.with(response: response, office: office).confirmation_email.deliver_later
  end
end
