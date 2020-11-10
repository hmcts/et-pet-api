FactoryBot.define do
  factory :command do
    transient do
      request_body_factory { nil }
    end
    request_headers do
      {
        "PATH_INFO"=>"/api/v2/respondents/build_response", "REMOTE_ADDR"=>"192.169.1.174", "SCRIPT_NAME"=>"", "SERVER_NAME"=>"et-api.employmenttribunal", "SERVER_PORT"=>"8080", "CONTENT_TYPE"=>"application/json", "QUERY_STRING"=>"", "CONTENT_LENGTH"=>"2326", "REQUEST_METHOD"=>"POST", "SERVER_PROTOCOL"=>"HTTP/1.1"
      }
    end
    response_headers do
      {
        "Content-Type"=>"application/json; charset=utf-8", "Referrer-Policy"=>"strict-origin-when-cross-origin", "X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Download-Options"=>"noopen", "X-Content-Type-Options"=>"nosniff", "X-Permitted-Cross-Domain-Policies"=>"none"
      }
    end
    response_status { 202 }
  end
  factory :build_response_command, parent: :command do
    transient do
      reference { '222000000300' }
      respondent_name { 'Fred Bloggs' }
      db_source { nil }
      additional_information_key { nil }
    end

    trait :default do
      request_body_factory { build(:json_build_response_commands) }
      request_body { request_body_factory.to_json }
      response_body do
        {
          status: :accepted,
          meta: {
            BuildResponse: {
              submitted_at: 10.days.ago,
              reference: reference,
              office_address: 'Doesnt matter',
              office_phone_number: '01234 567890',
              office_email: 'test@example.com',
              pdf_url: 'https://fairly.irrelevant.as.it.will.be.expired'
            },
            BuildRespondent: {},
            BuildRepresentative: {},
            BuildResponseAdditionalInformationFile: {}
          },
          uuid: request_body_factory.uuid
        }.to_json
      end
    end

    trait :from_db do
      request_body_factory do
        build :json_build_response_commands,
              response_attrs: db_source.attributes
                              .to_h
                              .with_indifferent_access.slice(:reference, :case_number, :claimants_name, :disagree_conciliation_reason,
                                                             :agree_with_employment_dates, :agree_with_claimants_description_of_job_or_title,
                                                             :continued_employment, :disagree_claimants_job_or_title, :disagree_employment,
                                                             :employment_end, :employment_start, :agree_with_earnings_details,
                                                             :agree_with_claimants_hours, :agree_with_claimant_notice,
                                                             :agree_with_claimant_pension_benefits, :queried_hours,
                                                             :queried_pay_before_tax, :queried_pay_before_tax_period,
                                                             :queried_take_home_pay, :queried_take_home_pay_period,
                                                             :disagree_claimant_notice_reason,
                                                             :disagree_claimant_pension_benefits_reason,
                                                             :defend_claim, :defend_claim_facts,
                                                             :claim_information, :make_employer_contract_claim)
                              .merge(additional_information_key: additional_information_key),
              respondent_attrs: db_source
                                .respondent.attributes
                                .to_h
                                .with_indifferent_access
                                .slice(:name, :contact, :address_telephone_number, :alt_phone_number, :dx_number, :fax_number, :organisation_more_than_one_site, :disability, :disability_information)
                                .merge(address_attributes: db_source.respondent.address.attributes.to_h.with_indifferent_access.slice(:building, :street, :locality, :county, :post_code)),
              representative_attrs: db_source
                                    .representative&.attributes
                                      &.to_h
                                      &.with_indifferent_access
                                      &.slice(:name, :organisation_name, :address_telephone_number, :mobile_number, :email_address, :representative_type, :dx_number, :reference, :contact_preference, :fax_number)
                                      &.merge(address_attributes: db_source.representative.address.attributes.to_h.with_indifferent_access.slice(:building, :street, :locality, :county, :post_code)),
              representative_traits: db_source.representative.present? ? [] : nil



      end
      request_body { request_body_factory.to_json }
      response_body do
        {
          status: :accepted,
          meta: {
            BuildResponse: {
              submitted_at: 10.days.ago,
              reference: reference,
              office_address: 'Doesnt matter',
              office_phone_number: '01234 567890',
              office_email: 'test@example.com',
              pdf_url: 'https://fairly.irrelevant.as.it.will.be.expired'
            },
            BuildRespondent: {},
            BuildRepresentative: {},
            BuildResponseAdditionalInformationFile: {}
          },
          uuid: request_body_factory.uuid
        }.to_json
      end
    end
  end
end
