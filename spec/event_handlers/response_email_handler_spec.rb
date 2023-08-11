require 'rails_helper'

describe ResponseEmailHandler do
  subject(:handler) { described_class.new }

  let(:response) { create(:response, :with_pdf_file, email_receipt: 'fred@bloggs.com') }

  it 'sends 1 email when called twice' do
    handler.handle(response)
    handler.handle(response)

    expect(ActionMailer::Base.deliveries.length).to be 1
  end
end
