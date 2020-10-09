RSpec.shared_context 'with gov uk notify emails sent monitor' do
  let!(:emails_sent) { EtApi::Test::GovUkNotifyEmailsSentMonitor.instance.start }
end
