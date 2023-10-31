require 'notifications/client'
class ResponseEmailHandler
  def handle(response, config: Rails.application.config.govuk_notify)
    send_email(response) unless !config.enabled || no_recipient?(response) || sent?(response)
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

    if response.email_template_reference.include?("v1")
      ResponseMailer.with(response: response, office: office, template_reference: template_reference).confirmation_email.deliver_now
      response.events.confirmation_email_sent.create
    else
      locale = template_reference.split('-').last
      client = build_client

      res = send_email_to_recipient response, client, find_template_id(client, template_reference), locale, response.email_receipt, office

      record_event(response, response.email_receipt, res)
    end
  end

  def find_template_id(client, template_reference)
    templates_collection = client.get_all_templates(type: :email)
    template = templates_collection.collection.detect do |t|
      t.name == template_reference.gsub(/\Aet3-/, 'et3-confirmation-email-')
    end
    raise "No template for reference: #{template_reference}" if template.blank?

    template.id
  end

  def record_event(response, email_recipient, res)
    if res.is_a?(Notifications::Client::ResponseNotification)
      response.events.confirmation_email_sent.create(data: { response: res.as_json.slice('id'), email_address: email_recipient })
    else
      response.events.confirmation_email_failed.create(data: { response: res.body, email_address: email_recipient })
    end
  end

  def send_email_to_recipient(response, client, template_id, locale, email_recipient, office)
    client.send_email email_address: email_recipient,
                      template_id: template_id,
                      personalisation: {
                        'office.name': office.name,
                        'office.address': office.address,
                        'office.telephone': office.telephone,
                        'response.reference': response.reference,
                        submitted_date: I18n.l(claim.date_of_receipt, format: '%d %B %Y', locale: locale)
                      }
  rescue Notifications::Client::RequestError => e
    e
  end
end
