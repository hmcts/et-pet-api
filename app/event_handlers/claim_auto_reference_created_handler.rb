class ClaimAutoReferenceCreatedHandler
  def handle(reference, office, email_address)
    ClaimantMailer.with(reference: reference, office: office, email_address: email_address).claim_auto_reference_email.deliver_later

  end
end
