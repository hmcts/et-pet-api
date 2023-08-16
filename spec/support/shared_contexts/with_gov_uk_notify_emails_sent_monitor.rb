RSpec.shared_context 'with gov uk notify emails sent monitor' do
  let(:emails_sent) { EtApi::Test::GovUkNotifyEmailsSentMonitor.instance }

  before do
    emails_sent.start
  end
end
