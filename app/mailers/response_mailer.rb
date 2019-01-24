class ResponseMailer < ApplicationMailer
  def confirmation_email
    @response = params[:response]
    @office = params[:office]
    @template_reference = params[:template_reference]
    attachments.inline["#{@response.reference}.pdf"] = @response.pdf_file.file.download
    mail to: @response.email_receipt,
         template_path: 'mailers/response_mailer',
         template_name: "confirmation_email.#{@template_reference}"
  end
end
