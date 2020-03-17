class FeedbackEmailHandler
  def handle(feedback_data)
    return unless Rails.application.config.service_now_inbox_email.present?
    FeedbackMailer.with(feedback_data: feedback_data).feedback_email.deliver_now
  end
end
