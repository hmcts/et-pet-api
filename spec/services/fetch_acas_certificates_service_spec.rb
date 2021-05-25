require 'rails_helper'

describe FetchAcasCertificatesService do
  before do
    stub_request(:any, /fakeservice\.com/).to_rack(EtFakeAcasServer::Server)
  end

  describe '.call' do
    subject(:service) { described_class.call(claim) }
    context 'claim with 6 respondents' do
      let(:claim) { create(:claim, :example_data, number_of_respondents: 6) }
      context 'starting from scratch' do
        it 'fetches primary and first 4 secondary respondents' do
          subject

          expect(claim.reload.uploaded_files.count).to be 5
        end

        it 'has no remaining ids if all successful' do
          expect(subject.remaining).to be_empty
        end

        it 'leaves an id as remaining if it fails with internal server error' do
          # Arrange - modify the third respondent to use the code to return 500 error
          respondent = claim.secondary_respondents[2]
          respondent.update! acas_certificate_number: 'NE000500/78/90'

          expect(subject.remaining).to eql [respondent.id]
        end

        it 'recovers when called twice when we get an internal server error which recovers 2nd time' do
          # Arrange - modify the third respondent to use the code to return 500 error
          #  and call the service for the first time, then modify the third respondent to use the code for success
          respondent = claim.secondary_respondents[2]
          respondent.update! acas_certificate_number: 'NE000500/78/90'
          described_class.call(claim)
          respondent.update! acas_certificate_number: 'NE000100/78/90'

          expect(subject.success?).to be true
        end

        it 'leaves an id as remaining if it fails with a connection timeout' do
          stub_request(:any, /fakeservice\.com/).to_timeout.to_rack(EtFakeAcasServer::Server)

          expect(subject.remaining).to eql [claim.primary_respondent_id]
        end

        it 'does not leave an id as remaining if it fails with not_found' do
          # Arrange - modify the third respondent to use the code to return 500 error
          respondent = claim.secondary_respondents[2]
          respondent.update acas_certificate_number: 'NE000200/78/90'

          expect(subject.remaining).to be_empty
        end

        it 'does not leave an id as remaining if it fails with invalid_certificate_format' do
          # Arrange - modify the third respondent to use the code to return 500 error
          respondent = claim.secondary_respondents[2]
          respondent.update acas_certificate_number: 'NE000201/78/90'

          expect(subject.remaining).to be_empty
        end

        it 'does not leave an id as remaining if the acas file is already present in the claim' do
          # Arrange - Store a file in the claim with the correct name
          claim.uploaded_files.create(filename: "acas_#{claim.primary_respondent.name}.pdf")

          expect(subject.remaining).to be_empty
        end

        it 'does not create a duplicate file if the file is already present in the claim' do
          # Arrange - Store a file in the claim with the correct name
          claim.uploaded_files.create(filename: "acas_#{claim.primary_respondent.name}.pdf")

          subject
          expect(claim.reload.uploaded_files.count).to be 5
        end

        it 'provides the extra files that were added' do
          # Arrange - Store a file in the claim with the correct name
          claim.uploaded_files.create(filename: "acas_#{claim.primary_respondent.name}.pdf")

          expect(subject.new_files.length).to be 4
        end

        it 'provides the extra files that were added after recovering from an error' do
          # Arrange - Store a file in the claim with the correct name
          # Arrange - modify the third respondent to use the code to return 500 error
          #  and call the service for the first time, then modify the third respondent to use the code for success
          claim.uploaded_files.create(filename: "acas_#{claim.primary_respondent.name}.pdf")
          respondent = claim.secondary_respondents[2]
          respondent.update! acas_certificate_number: 'NE000500/78/90'
          described_class.call(claim)
          respondent.update! acas_certificate_number: 'NE000100/78/90'

          expect(subject.new_files.length).to be 4
        end
      end
    end
  end
end
