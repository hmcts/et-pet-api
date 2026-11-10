require 'rails_helper'
RSpec.describe "create claim multiples (active job)" do
  let(:job) { EtExporter::ExportClaimJob }
  let(:test_ccd_client) { EtCcdClient::UiClient.new.tap { |c| c.login(username: 'm@m.com', password: 'Pa55word11') } }

  include_context 'with stubbed ccd'

  before do
    stub_request(:get, "http://dummy.com/examplepdf").
      to_return(status: 200, body: File.new(Rails.root.join('spec/fixtures/chloe_goodwin.pdf')), headers: { 'Content-Type' => 'application/pdf' })
    stub_request(:get, "http://dummy.com/examplecsv").
      to_return(status: 200, body: File.new(Rails.root.join('spec/fixtures/example.csv')), headers: { 'Content-Type' => 'text/csv' })
  end

  it 'creates a multiples claim referencing many single claims in ccd' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    aggregate_failures 'validating key fields' do
      expect(ccd_case['case_fields']).to include 'multipleName' => export.resource.primary_respondent.name
      case_references = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }
      expect(case_references.length).to eql(export.resource.secondary_claimants.length + 1)
      expect(case_references).to all be_an_instance_of(String)
    end
  end

  it 'acts as created if a duplicate exists' do
    # Arrange - Produce the input JSON and create an existing case
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants]).tap do |instance|
      instance.resource.secondary_claimants[5] = build(:ccd_export_claimant, :force_error_timeout_then_conflict)
    end
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs
    multiples_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    expect(external_events).to have_published_multiples_claim_export_succeeded(export: export, ccd_case: multiples_case)
  end

  it 'does not process a claim with too many claimants' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, :limited_multiples_count, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check that the event has been sent to the api
    expect(external_events).to have_published_multiples_claim_size_exceeded(export: export)
  end

  it 'raises an API event to inform of start of case creation' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    expect(external_events).to have_published_multiples_claim_export_started(export:)
  end

  it 'raises an API event to inform of case creation complete' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    multiples_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    expect(external_events).to have_published_multiples_claim_export_succeeded(export: export, ccd_case: multiples_case)
  end

  it 'raises an API event for every sub case showing progress' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    multiples_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_references = multiples_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }
    sub_cases = case_references.map do |ref|
      test_ccd_client.caseworker_search_latest_by_ethos_case_reference(ref, case_type_id: 'Manchester')
    end
    expect(external_events).to have_published_all_multiples_claim_export_progress(export: export, ccd_case: multiples_case, sub_cases: sub_cases)
  end

  it 'raises an API event to inform of an error in one of the sub cases' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])
    erroring_claimant = export.resource.secondary_claimants[2]
    erroring_claimant.first_name = 'Force'
    erroring_claimant.last_name = 'Error502'

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    begin
      drain_all_our_jobs
    rescue EtCcdClient::Exceptions::Base, EtCcdExport::ApplicationException
      nil
    end
    # Assert - Check for API event being received
    expect(external_events).to have_published_sub_claim_erroring(export: export)
  end

  it 'has the primary claimant first when the jobs are processed in order' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    primary_claimant = export.resource.primary_claimant
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_references = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }
    aggregate_failures 'validating key fields' do
      created_case = test_ccd_client.caseworker_search_latest_by_ethos_case_reference(case_references.first, case_type_id: 'Manchester')
      expect(created_case['case_fields']).to include \
        'claimantIndType' => a_hash_including(
          'claimant_title1' => primary_claimant.title,
          'claimant_first_names' => primary_claimant.first_name,
          'claimant_last_name' => primary_claimant.last_name
        )
    end
  end

  it 'has the primary claimant first when the jobs are processed in reverse order' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)

    drain_all_our_jobs

    # Assert - After calling all of our workers like active job would, check with CCD (or fake CCD) to see what we sent
    primary_claimant = export.resource.primary_claimant
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_references = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }
    aggregate_failures 'validating key fields' do
      created_case = test_ccd_client.caseworker_search_latest_by_ethos_case_reference(case_references.first, case_type_id: 'Manchester')
      expect(created_case['case_fields']).to include \
        'claimantIndType' => a_hash_including(
          'claimant_title1' => primary_claimant.title,
          'claimant_first_names' => primary_claimant.first_name,
          'claimant_last_name' => primary_claimant.last_name
        )
    end
  end

  it 'creates a lead claim in ccd that is marked as the lead' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - Check with CCD (or fake CCD) to see what we sent
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_reference = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }.first
    aggregate_failures 'validating lead claimant' do
      lead_case = test_ccd_client.caseworker_search_latest_by_ethos_case_reference(case_reference, case_type_id: 'Manchester')
      expect(lead_case.dig('case_fields', 'leadClaimant')).to eql 'Yes'
    end
  end

  it 'creates a non lead claim in ccd that is not marked as the lead' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - Check with CCD (or fake CCD) to see what we sent
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_reference = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }[1]
    aggregate_failures 'validating lead claimant' do
      lead_case = test_ccd_client.caseworker_search_latest_by_ethos_case_reference(case_reference, case_type_id: 'Manchester')
      expect(lead_case.dig('case_fields', 'leadClaimant')).to eql 'No'
    end
  end

  it 'populates the multipleReference in every case' do
    # Arrange - Produce the input JSON
    export = build(:ccd_export_export, :for_claim, claim_traits: [:default_multiple_claimants])

    # Run the export job and its child jobs.
    job.perform_later(export.as_json.to_json)
    drain_all_our_jobs

    # Assert - Check with CCD (or fake CCD) to see what we sent
    ccd_case = test_ccd_client.caseworker_search_latest_by_bulk_case_title(export.resource.primary_respondent.name, case_type_id: 'Manchester_Multiples')
    case_references = ccd_case.dig('case_fields', 'caseIdCollection').map { |obj| obj.dig('value', 'ethos_CaseReference') }
    cases = test_ccd_client.caseworker_search_by_multiple_reference(ccd_case.dig('case_fields', 'multipleReference'), case_type_id: 'Manchester')
    expect(cases.length).to eql case_references.length
  end

end
