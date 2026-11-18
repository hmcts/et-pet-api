require 'rails_helper'

RSpec.describe 'CCD claim export recovery' do
  let(:job) { EtExporter::ExportClaimJob }
  let(:test_ccd_client) { EtCcdClient::UiClient.new.tap(&:login) }

  include_context 'with stubbed ccd'

  before do
    stub_request(:get, 'http://dummy.com/examplepdf').to_return(
      status: 200, body: File.binread(Rails.root.join('spec/fixtures/chloe_goodwin.pdf')),
      headers: { 'Content-Type' => 'application/pdf' }
    )
  end

  it 'acts as created if a duplicate exists' do
    export = build(
      :ccd_export_export,
      :for_claim,
      claim_attrs: {
        primary_claimant_traits: [:force_error_timeout_then_conflict]
      }
    )

    job.perform_later(export.as_json.to_json)
    perform_enqueued_jobs only: job
    perform_enqueued_jobs only: job, at: 1.minute.from_now

    ccd_case = test_ccd_client.caseworker_search_latest_by_reference(
      export.resource.reference,
      case_type_id: 'Manchester'
    )

    expect(ccd_case['case_fields']).to include(
      'feeGroupReference' => export.resource.reference
    )
    expect(external_events).to have_published_claim_export_succeeded(export: export, ccd_case: ccd_case)
  end
end
