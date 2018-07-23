class ResponseMailer < ApplicationMailer
  def confirmation_email
    @response = params[:response]
    @office = params[:office]
    attachments.inline["#{@response.reference}.pdf"] = @response.pdf_file.file.download
    mail to: @response.respondent.email_address,
         subject: 'Your Response to Employment Tribunal claim online form receipt',
         template_path: 'mailers/response_mailer'
  end
end
