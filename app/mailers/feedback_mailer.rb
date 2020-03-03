class FeedbackMailer < ApplicationMailer
  def feedback_email(service_now_email: Rails.application.config.service_now_inbox_email)
    @feedback_data = params[:feedback_data]
    mail(from: @feedback_data["email_address"], to: service_now_email, subject: 'Your feedback to Employment Tribunal', template_path: 'mailers/feedback_mailer')
  end
end
