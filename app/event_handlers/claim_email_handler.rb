require 'notifications/client'
class ClaimEmailHandler
  MAX_FILE_SIZE = (2 * 1024 * 1024)
  def handle(claim, config: Rails.application.config.govuk_notify)
    send_email(claim, config: config) unless has_no_recipients?(claim) || sent?(claim)
  end

  private

  def has_no_recipients?(claim)
    claim.confirmation_email_recipients.empty?
  end

  def sent?(claim)
    claim.events.confirmation_email_sent.present?
  end

  def send_email(claim, template_reference: claim.email_template_reference, config:)
    return unless config.enabled

    api_key = config["#{config.mode}_api_key"]
    client = Notifications::Client.new(api_key)

    locale = template_reference.split('-').last

    pdf_file = download_to_tempfile claim.uploaded_files.et1_pdf.first
    rtf_file = download_to_tempfile claim.uploaded_files.et1_rtf.first
    csv_file = download_to_tempfile claim.uploaded_files.et1_csv.first
    link_to_pdf = Notifications.prepare_upload(pdf_file)
    link_to_rtf = rtf_file.present? && rtf_file.size < MAX_FILE_SIZE ? Notifications.prepare_upload(rtf_file) : I18n.t('et1_confirmation_email.rtf_not_submitted', locale: locale)
    link_to_csv = csv_file.present? && csv_file.size < MAX_FILE_SIZE ? Notifications.prepare_upload(csv_file) : I18n.t('et1_confirmation_email.csv_not_submitted', locale: locale)

    office = OfficeService.lookup_by_case_number(claim.reference)
    claim.confirmation_email_recipients.each do |email_recipient|
      response = send_email_to_recipient claim, client, find_template_id(client, template_reference),
                                         locale, email_recipient, link_to_pdf, rtf_file, link_to_rtf, csv_file, link_to_csv, office
      record_event(claim, email_recipient, response)
    end
  end

  def find_template_id(client, template_reference)
    templates_collection = client.get_all_templates(type: :email)
    template = templates_collection.collection.detect do |t|
      t.name == template_reference.gsub(/\Aet1-/, 'et1-confirmation-email-')
    end
    raise "No template for reference: #{template_reference}" unless template.present?

    template.id
  end

  def record_event(claim, email_recipient, response)
    if response.is_a?(Notifications::Client::ResponseNotification)
      claim.events.confirmation_email_sent.create(data: { response: response.as_json.slice('id'), email_address: email_recipient })
    else
      claim.events.confirmation_email_failed.create(data: { response: response.body, email_address: email_recipient })
    end
  end

  def send_email_to_recipient(claim, client, template_id, locale, email_recipient, link_to_pdf, rtf_file, link_to_rtf, csv_file, link_to_csv, office)
    client.send_email email_address: email_recipient,
                                       template_id: template_id,
                                       personalisation: {
                                         'claim.reference': claim.reference,
                                         'primary_claimant.first_name': claim.primary_claimant.first_name,
                                         'primary_claimant.last_name': claim.primary_claimant.last_name,
                                         'submitted_date': I18n.l(claim.date_of_receipt, format: '%d %B %Y', locale: locale),
                                         'office.name': office.name,
                                         'office.email': office.email,
                                         'office.telephone': office.telephone,
                                         'link_to_pdf': link_to_pdf,
                                         'has_additional_info': rtf_file.present? ? 'yes' : 'no',
                                         'link_to_additional_info': link_to_rtf,
                                         'has_claimants_file': csv_file.present? ? 'yes' : 'no',
                                         'link_to_claimants_file': link_to_csv
                                       }
  rescue Notifications::Client::RequestError => ex
    ex
  end

  def download_to_tempfile(uploaded_file)
    return nil if uploaded_file.nil?

    Tempfile.new.tap do |tempfile|
      uploaded_file.download_blob_to(tempfile.path)
    end
  end
end
