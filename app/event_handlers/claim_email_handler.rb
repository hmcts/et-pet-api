require 'notifications/client'
class ClaimEmailHandler
  def handle(claim, config: Rails.application.config.govuk_notify)
    send_email(claim) unless !config.enabled || no_recipients?(claim) || sent?(claim)
  end

  private

  def no_recipients?(claim)
    claim.confirmation_email_recipients.empty?
  end

  def sent?(claim)
    claim.events.confirmation_email_sent.present?
  end

  def build_client(config: Rails.application.config.govuk_notify)
    api_key = config["#{config.mode}_api_key"]
    args = []
    args << config.custom_url unless config.custom_url == false
    Notifications::Client.new(api_key, *args)
  end

  def send_email(claim, template_reference: claim.email_template_reference)
    locale = template_reference.split('-').last
    client = build_client

    office = OfficeService.lookup_by_case_number(claim.reference)
    claim.confirmation_email_recipients.each do |email_recipient|
      response = send_email_to_recipient claim, client, find_template_id(client, template_reference),
                                         locale, email_recipient, office
      record_event(claim, email_recipient, response)
    end
  end

  def find_template_id(client, template_reference)
    templates_collection = client.get_all_templates(type: :email)
    template = templates_collection.collection.detect do |t|
      t.name == template_reference.gsub(/\Aet1-/, 'et1-confirmation-email-')
    end
    raise "No template for reference: #{template_reference}" if template.blank?

    template.id
  end

  def record_event(claim, email_recipient, response)
    if response.is_a?(Notifications::Client::ResponseNotification)
      claim.events.confirmation_email_sent.create(data: { response: response.as_json.slice('id'), email_address: email_recipient })
    else
      claim.events.confirmation_email_failed.create(data: { response: response.body, email_address: email_recipient })
    end
  end

  def send_email_to_recipient(claim, client, template_id, locale, email_recipient, office)
    client.send_email email_address: email_recipient,
                      template_id: template_id,
                      personalisation: personalisation_data_for(claim, office, locale)
  rescue Notifications::Client::RequestError => e
    e
  end

  def personalisation_data_for(claim, office, locale)
    additional_info_file, additional_info_text = additional_info(claim, locale)
    csv_file, csv_text = csv_info(claim, locale)

    {
      'claim.reference': claim.reference,
      'primary_claimant.first_name': claim.primary_claimant.first_name,
      'primary_claimant.last_name': claim.primary_claimant.last_name,
      submitted_date: I18n.l(claim.date_of_receipt, format: '%d %B %Y', locale: locale),
      'office.name': office.name, 'office.email': office.email, 'office.telephone': office.telephone,
      link_to_pdf: link_to_pdf(claim),
      has_additional_info: additional_info_file.present? ? 'yes' : 'no', link_to_additional_info: additional_info_text,
      has_claimants_file: csv_file.present? ? 'yes' : 'no', link_to_claimants_file: csv_text
    }
  end

  def download_to_tempfile(uploaded_file)
    return nil if uploaded_file.nil?

    Tempfile.new.tap do |tempfile|
      uploaded_file.download_blob_to(tempfile.path)
    end
  end

  def link_to_pdf(claim)
    pdf_file = download_to_tempfile claim.uploaded_files.et1_pdf.first
    Notifications.prepare_upload(pdf_file)
  end

  def additional_info(claim, locale, number_helper: ActiveSupport::NumberHelper)
    additional_info_file = claim.uploaded_files.et1_input_claim_details.first
    additional_info_text = if additional_info_file.present?
                             file_size = number_helper.number_to_human_size additional_info_file.file.byte_size,
                                                                            locale: locale
                             I18n.t 'et1_confirmation_email.claim_details_file_submitted',
                                    name: additional_info_file.filename,
                                    size: file_size,
                                    locale: locale
                           else
                             I18n.t('et1_confirmation_email.claim_details_file_not_submitted', locale: locale)
                           end
    [additional_info_file, additional_info_text]
  end

  def csv_info(claim, locale, number_helper: ActiveSupport::NumberHelper)
    csv_uploaded_file = claim.uploaded_files.et1_csv.first
    csv_text = if csv_uploaded_file.present?
                 file_size = number_helper.number_to_human_size csv_uploaded_file.file.byte_size,
                                                                locale: locale
                 I18n.t 'et1_confirmation_email.csv_submitted',
                        name: csv_uploaded_file.filename,
                        size: file_size,
                        locale: locale
               else
                 I18n.t('et1_confirmation_email.csv_not_submitted', locale: locale)
               end
    [csv_uploaded_file, csv_text]
  end
end
