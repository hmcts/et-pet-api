require 'rails_helper'

describe ClaimEmailHandler do
  subject(:handler) { described_class.new }
  let(:claim) { create(:claim, confirmation_email_recipients: ['fred@bloggs.com']) }
  it 'sends 1 email when called twice' do
    handler.handle(claim)
    handler.handle(claim)
    expect(ActionMailer::Base.deliveries.length).to be 1
  end
end
