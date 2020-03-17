class ClaimMailer < ApplicationMailer
  def confirmation_email
    @claim = params[:claim]
    @office = params[:office]
    @template_reference = params[:template_reference]
    user_files.each do |user_file|
      attachments.inline[user_file.filename] = user_file.file.download
    end
    mail to: @claim.confirmation_email_recipients,
         template_path: 'mailers/claim_mailer',
         template_name: "confirmation_email.#{@template_reference}"
  end

  private

  def user_files
    @claim.uploaded_files.not_hidden
  end
end
