class ClaimantMailer < ApplicationMailer
  def claim_auto_reference_email
    mail(to: params[:email_address],
         body: 'Hello World',
         content_type: 'text/plain',
         subject: 'Employment Tribunal Submission')
  end
end
