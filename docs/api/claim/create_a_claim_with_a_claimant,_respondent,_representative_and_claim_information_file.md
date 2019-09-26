# Claim API

A claim is the claim made by the claimant against the respondent (employer)

## Create a claim with a claimant, respondent, representative and claim information file

### POST /api/v2/claims/build_claim

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | An array of commands to execute to build the complete claim | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/claims/build_claim</pre>

#### Body

<pre>{
  "uuid": "b52445bc-c658-49c6-8940-fa35a0b20f90",
  "command": "SerialSequence",
  "data": [
    {
      "uuid": "ce955866-61c5-48e2-856d-be52c121bbd7",
      "command": "BuildClaim",
      "data": {
        "employment_details": {
          "start_date": "2009-11-18",
          "end_date": null,
          "notice_period_end_date": null,
          "job_title": "agriculturist",
          "average_hours_worked_per_week": 38.0,
          "gross_pay": 3000,
          "gross_pay_period_type": "monthly",
          "net_pay": 2000,
          "net_pay_period_type": "monthly",
          "worked_notice_period_or_paid_in_lieu": null,
          "notice_pay_period_type": null,
          "notice_pay_period_count": null,
          "enrolled_in_pension_scheme": true,
          "benefit_details": "Company car, private health care",
          "found_new_job": null,
          "new_job_start_date": null,
          "new_job_gross_pay": null
        },
        "reference": "222000000300",
        "submission_reference": "J704-ZK5E",
        "submission_channel": "Web",
        "case_type": "Single",
        "jurisdiction": "2",
        "office_code": "22",
        "date_of_receipt": "2019-09-26T11:37:49+0000",
        "other_known_claimant_names": "",
        "discrimination_claims": [

        ],
        "pay_claims": [

        ],
        "desired_outcomes": [

        ],
        "other_claim_details": "",
        "claim_details": "",
        "other_outcome": "",
        "send_claim_to_whistleblowing_entity": false,
        "miscellaneous_information": "",
        "is_unfair_dismissal": false,
        "pdf_template_reference": "et1-v1-en"
      }
    },
    {
      "uuid": "07f362fc-08d0-4995-8482-b516407b8758",
      "command": "BuildPrimaryRespondent",
      "data": {
        "name": "dodgy_co",
        "address_attributes": {
          "building": "the_shard",
          "street": "downing_street",
          "locality": "westminster",
          "county": "",
          "post_code": "wc1 1aa"
        },
        "organisation_more_than_one_site": false,
        "work_address_attributes": {
          "building": "the_shard",
          "street": "downing_street",
          "locality": "westminster",
          "county": "",
          "post_code": "wc1 1aa"
        },
        "contact": "John Smith",
        "dx_number": "",
        "address_telephone_number": "",
        "work_address_telephone_number": "",
        "alt_phone_number": "",
        "contact_preference": "email",
        "email_address": "john@dodgyco.com",
        "fax_number": "",
        "organisation_employ_gb": 10,
        "employment_at_site_number": 5,
        "disability": true,
        "disability_information": "Lorem ipsum disability",
        "acas_certificate_number": "AC123456/78/90",
        "acas_exemption_code": null
      }
    },
    {
      "uuid": "97e3939b-52b3-4019-85ca-a150b2376536",
      "command": "BuildPrimaryClaimant",
      "data": {
        "title": "Mr",
        "first_name": "First",
        "last_name": "Last",
        "address_attributes": {
          "building": "102",
          "street": "Petty France",
          "locality": "London",
          "county": "Greater London",
          "post_code": "SW1H 9AJ",
          "country": "United Kingdom"
        },
        "address_telephone_number": "01234 567890",
        "mobile_number": "01234 098765",
        "email_address": "test@digital.justice.gov.uk",
        "fax_number": null,
        "contact_preference": "Email",
        "gender": "Male",
        "date_of_birth": "1982-11-21",
        "special_needs": null
      }
    },
    {
      "uuid": "468966a6-6eba-4926-96e4-fb418b2b7c20",
      "command": "BuildSecondaryClaimants",
      "data": [
        {
          "title": "Mr",
          "first_name": "First",
          "last_name": "Last",
          "address_attributes": {
            "building": "102",
            "street": "Petty France",
            "locality": "London",
            "county": "Greater London",
            "post_code": "SW1H 9AJ"
          },
          "address_telephone_number": "01234 567890",
          "mobile_number": "01234 098765",
          "email_address": "test@digital.justice.gov.uk",
          "fax_number": null,
          "contact_preference": "Email",
          "gender": "Male",
          "date_of_birth": "1982-11-21",
          "special_needs": null
        }
      ]
    },
    {
      "uuid": "7402e8e0-9b6d-4ab6-b2e2-a0178ac01814",
      "command": "BuildSecondaryRespondents",
      "data": [
        {
          "name": "dodgy_co",
          "address_attributes": {
            "building": "the_shard",
            "street": "downing_street",
            "locality": "westminster",
            "county": "",
            "post_code": "wc1 1aa"
          },
          "organisation_more_than_one_site": false,
          "work_address_attributes": {
            "building": "the_shard",
            "street": "downing_street",
            "locality": "westminster",
            "county": "",
            "post_code": "wc1 1aa"
          },
          "contact": "John Smith",
          "dx_number": "",
          "address_telephone_number": "",
          "work_address_telephone_number": "",
          "alt_phone_number": "",
          "contact_preference": "email",
          "email_address": "john@dodgyco.com",
          "fax_number": "",
          "organisation_employ_gb": 10,
          "employment_at_site_number": 5,
          "disability": true,
          "disability_information": "Lorem ipsum disability",
          "acas_certificate_number": "AC123456/78/90",
          "acas_exemption_code": null
        }
      ]
    },
    {
      "uuid": "c28620ef-babf-491e-9605-62824ed6d5dd",
      "command": "BuildPrimaryRepresentative",
      "data": {
        "address_attributes": {
          "building": "Rep Building",
          "street": "Rep Street",
          "locality": "Rep Town",
          "county": "Rep County",
          "post_code": "WC2 2BB"
        },
        "name": "Jane Doe",
        "organisation_name": "repco ltd",
        "address_telephone_number": "0207 987 6543",
        "mobile_number": "07987654321",
        "representative_type": "Private Individual",
        "dx_number": "dx address",
        "reference": "Rep Ref",
        "contact_preference": "fax",
        "email_address": "test@email.com",
        "fax_number": "0207 345 6789"
      }
    },
    {
      "uuid": "1b3b5361-8ca6-409f-b7ef-15583d7d4b23",
      "command": "BuildPdfFile",
      "data": {
        "data_url": "http://localhost:10000/devstoreaccount1/et-api-container/mcdax0v8ax27xn794i5dpiw9bufl?sp=r&sv=2016-05-31&se=2019-10-06T11%3A37%3A49Z&rscd=inline%3B+filename%3D%22et1_first_last.pdf%22%3B+filename*%3DUTF-8%27%27et1_first_last.pdf&rsct=application%2Fpdf&sr=b&sig=dXsFNeBHFKSpNqrg3NA1MrSC0CRd5u2qrOHOjXdTF2A%3D",
        "data_from_key": null,
        "filename": "et1_first_last.pdf",
        "checksum": "ee2714b8b731a8c1e95dffaa33f89728"
      }
    },
    {
      "uuid": "62a7016e-6a82-49fb-b2c6-1bdf3a280d71",
      "command": "BuildClaimDetailsFile",
      "data": {
        "data_url": null,
        "data_from_key": "wneo1ogqehw1i8xgimee6xq3vfu4",
        "filename": "simple_user_with_rtf.rtf",
        "checksum": "e69a0344620b5040b7d0d1595b9c7726"
      }
    }
  ]
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/claims/build_claim&quot; -d &#39;{
  &quot;uuid&quot;: &quot;b52445bc-c658-49c6-8940-fa35a0b20f90&quot;,
  &quot;command&quot;: &quot;SerialSequence&quot;,
  &quot;data&quot;: [
    {
      &quot;uuid&quot;: &quot;ce955866-61c5-48e2-856d-be52c121bbd7&quot;,
      &quot;command&quot;: &quot;BuildClaim&quot;,
      &quot;data&quot;: {
        &quot;employment_details&quot;: {
          &quot;start_date&quot;: &quot;2009-11-18&quot;,
          &quot;end_date&quot;: null,
          &quot;notice_period_end_date&quot;: null,
          &quot;job_title&quot;: &quot;agriculturist&quot;,
          &quot;average_hours_worked_per_week&quot;: 38.0,
          &quot;gross_pay&quot;: 3000,
          &quot;gross_pay_period_type&quot;: &quot;monthly&quot;,
          &quot;net_pay&quot;: 2000,
          &quot;net_pay_period_type&quot;: &quot;monthly&quot;,
          &quot;worked_notice_period_or_paid_in_lieu&quot;: null,
          &quot;notice_pay_period_type&quot;: null,
          &quot;notice_pay_period_count&quot;: null,
          &quot;enrolled_in_pension_scheme&quot;: true,
          &quot;benefit_details&quot;: &quot;Company car, private health care&quot;,
          &quot;found_new_job&quot;: null,
          &quot;new_job_start_date&quot;: null,
          &quot;new_job_gross_pay&quot;: null
        },
        &quot;reference&quot;: &quot;222000000300&quot;,
        &quot;submission_reference&quot;: &quot;J704-ZK5E&quot;,
        &quot;submission_channel&quot;: &quot;Web&quot;,
        &quot;case_type&quot;: &quot;Single&quot;,
        &quot;jurisdiction&quot;: &quot;2&quot;,
        &quot;office_code&quot;: &quot;22&quot;,
        &quot;date_of_receipt&quot;: &quot;2019-09-26T11:37:49+0000&quot;,
        &quot;other_known_claimant_names&quot;: &quot;&quot;,
        &quot;discrimination_claims&quot;: [

        ],
        &quot;pay_claims&quot;: [

        ],
        &quot;desired_outcomes&quot;: [

        ],
        &quot;other_claim_details&quot;: &quot;&quot;,
        &quot;claim_details&quot;: &quot;&quot;,
        &quot;other_outcome&quot;: &quot;&quot;,
        &quot;send_claim_to_whistleblowing_entity&quot;: false,
        &quot;miscellaneous_information&quot;: &quot;&quot;,
        &quot;is_unfair_dismissal&quot;: false,
        &quot;pdf_template_reference&quot;: &quot;et1-v1-en&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;07f362fc-08d0-4995-8482-b516407b8758&quot;,
      &quot;command&quot;: &quot;BuildPrimaryRespondent&quot;,
      &quot;data&quot;: {
        &quot;name&quot;: &quot;dodgy_co&quot;,
        &quot;address_attributes&quot;: {
          &quot;building&quot;: &quot;the_shard&quot;,
          &quot;street&quot;: &quot;downing_street&quot;,
          &quot;locality&quot;: &quot;westminster&quot;,
          &quot;county&quot;: &quot;&quot;,
          &quot;post_code&quot;: &quot;wc1 1aa&quot;
        },
        &quot;organisation_more_than_one_site&quot;: false,
        &quot;work_address_attributes&quot;: {
          &quot;building&quot;: &quot;the_shard&quot;,
          &quot;street&quot;: &quot;downing_street&quot;,
          &quot;locality&quot;: &quot;westminster&quot;,
          &quot;county&quot;: &quot;&quot;,
          &quot;post_code&quot;: &quot;wc1 1aa&quot;
        },
        &quot;contact&quot;: &quot;John Smith&quot;,
        &quot;dx_number&quot;: &quot;&quot;,
        &quot;address_telephone_number&quot;: &quot;&quot;,
        &quot;work_address_telephone_number&quot;: &quot;&quot;,
        &quot;alt_phone_number&quot;: &quot;&quot;,
        &quot;contact_preference&quot;: &quot;email&quot;,
        &quot;email_address&quot;: &quot;john@dodgyco.com&quot;,
        &quot;fax_number&quot;: &quot;&quot;,
        &quot;organisation_employ_gb&quot;: 10,
        &quot;employment_at_site_number&quot;: 5,
        &quot;disability&quot;: true,
        &quot;disability_information&quot;: &quot;Lorem ipsum disability&quot;,
        &quot;acas_certificate_number&quot;: &quot;AC123456/78/90&quot;,
        &quot;acas_exemption_code&quot;: null
      }
    },
    {
      &quot;uuid&quot;: &quot;97e3939b-52b3-4019-85ca-a150b2376536&quot;,
      &quot;command&quot;: &quot;BuildPrimaryClaimant&quot;,
      &quot;data&quot;: {
        &quot;title&quot;: &quot;Mr&quot;,
        &quot;first_name&quot;: &quot;First&quot;,
        &quot;last_name&quot;: &quot;Last&quot;,
        &quot;address_attributes&quot;: {
          &quot;building&quot;: &quot;102&quot;,
          &quot;street&quot;: &quot;Petty France&quot;,
          &quot;locality&quot;: &quot;London&quot;,
          &quot;county&quot;: &quot;Greater London&quot;,
          &quot;post_code&quot;: &quot;SW1H 9AJ&quot;,
          &quot;country&quot;: &quot;United Kingdom&quot;
        },
        &quot;address_telephone_number&quot;: &quot;01234 567890&quot;,
        &quot;mobile_number&quot;: &quot;01234 098765&quot;,
        &quot;email_address&quot;: &quot;test@digital.justice.gov.uk&quot;,
        &quot;fax_number&quot;: null,
        &quot;contact_preference&quot;: &quot;Email&quot;,
        &quot;gender&quot;: &quot;Male&quot;,
        &quot;date_of_birth&quot;: &quot;1982-11-21&quot;,
        &quot;special_needs&quot;: null
      }
    },
    {
      &quot;uuid&quot;: &quot;468966a6-6eba-4926-96e4-fb418b2b7c20&quot;,
      &quot;command&quot;: &quot;BuildSecondaryClaimants&quot;,
      &quot;data&quot;: [
        {
          &quot;title&quot;: &quot;Mr&quot;,
          &quot;first_name&quot;: &quot;First&quot;,
          &quot;last_name&quot;: &quot;Last&quot;,
          &quot;address_attributes&quot;: {
            &quot;building&quot;: &quot;102&quot;,
            &quot;street&quot;: &quot;Petty France&quot;,
            &quot;locality&quot;: &quot;London&quot;,
            &quot;county&quot;: &quot;Greater London&quot;,
            &quot;post_code&quot;: &quot;SW1H 9AJ&quot;
          },
          &quot;address_telephone_number&quot;: &quot;01234 567890&quot;,
          &quot;mobile_number&quot;: &quot;01234 098765&quot;,
          &quot;email_address&quot;: &quot;test@digital.justice.gov.uk&quot;,
          &quot;fax_number&quot;: null,
          &quot;contact_preference&quot;: &quot;Email&quot;,
          &quot;gender&quot;: &quot;Male&quot;,
          &quot;date_of_birth&quot;: &quot;1982-11-21&quot;,
          &quot;special_needs&quot;: null
        }
      ]
    },
    {
      &quot;uuid&quot;: &quot;7402e8e0-9b6d-4ab6-b2e2-a0178ac01814&quot;,
      &quot;command&quot;: &quot;BuildSecondaryRespondents&quot;,
      &quot;data&quot;: [
        {
          &quot;name&quot;: &quot;dodgy_co&quot;,
          &quot;address_attributes&quot;: {
            &quot;building&quot;: &quot;the_shard&quot;,
            &quot;street&quot;: &quot;downing_street&quot;,
            &quot;locality&quot;: &quot;westminster&quot;,
            &quot;county&quot;: &quot;&quot;,
            &quot;post_code&quot;: &quot;wc1 1aa&quot;
          },
          &quot;organisation_more_than_one_site&quot;: false,
          &quot;work_address_attributes&quot;: {
            &quot;building&quot;: &quot;the_shard&quot;,
            &quot;street&quot;: &quot;downing_street&quot;,
            &quot;locality&quot;: &quot;westminster&quot;,
            &quot;county&quot;: &quot;&quot;,
            &quot;post_code&quot;: &quot;wc1 1aa&quot;
          },
          &quot;contact&quot;: &quot;John Smith&quot;,
          &quot;dx_number&quot;: &quot;&quot;,
          &quot;address_telephone_number&quot;: &quot;&quot;,
          &quot;work_address_telephone_number&quot;: &quot;&quot;,
          &quot;alt_phone_number&quot;: &quot;&quot;,
          &quot;contact_preference&quot;: &quot;email&quot;,
          &quot;email_address&quot;: &quot;john@dodgyco.com&quot;,
          &quot;fax_number&quot;: &quot;&quot;,
          &quot;organisation_employ_gb&quot;: 10,
          &quot;employment_at_site_number&quot;: 5,
          &quot;disability&quot;: true,
          &quot;disability_information&quot;: &quot;Lorem ipsum disability&quot;,
          &quot;acas_certificate_number&quot;: &quot;AC123456/78/90&quot;,
          &quot;acas_exemption_code&quot;: null
        }
      ]
    },
    {
      &quot;uuid&quot;: &quot;c28620ef-babf-491e-9605-62824ed6d5dd&quot;,
      &quot;command&quot;: &quot;BuildPrimaryRepresentative&quot;,
      &quot;data&quot;: {
        &quot;address_attributes&quot;: {
          &quot;building&quot;: &quot;Rep Building&quot;,
          &quot;street&quot;: &quot;Rep Street&quot;,
          &quot;locality&quot;: &quot;Rep Town&quot;,
          &quot;county&quot;: &quot;Rep County&quot;,
          &quot;post_code&quot;: &quot;WC2 2BB&quot;
        },
        &quot;name&quot;: &quot;Jane Doe&quot;,
        &quot;organisation_name&quot;: &quot;repco ltd&quot;,
        &quot;address_telephone_number&quot;: &quot;0207 987 6543&quot;,
        &quot;mobile_number&quot;: &quot;07987654321&quot;,
        &quot;representative_type&quot;: &quot;Private Individual&quot;,
        &quot;dx_number&quot;: &quot;dx address&quot;,
        &quot;reference&quot;: &quot;Rep Ref&quot;,
        &quot;contact_preference&quot;: &quot;fax&quot;,
        &quot;email_address&quot;: &quot;test@email.com&quot;,
        &quot;fax_number&quot;: &quot;0207 345 6789&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;1b3b5361-8ca6-409f-b7ef-15583d7d4b23&quot;,
      &quot;command&quot;: &quot;BuildPdfFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: &quot;http://localhost:10000/devstoreaccount1/et-api-container/mcdax0v8ax27xn794i5dpiw9bufl?sp=r&amp;sv=2016-05-31&amp;se=2019-10-06T11%3A37%3A49Z&amp;rscd=inline%3B+filename%3D%22et1_first_last.pdf%22%3B+filename*%3DUTF-8%27%27et1_first_last.pdf&amp;rsct=application%2Fpdf&amp;sr=b&amp;sig=dXsFNeBHFKSpNqrg3NA1MrSC0CRd5u2qrOHOjXdTF2A%3D&quot;,
        &quot;data_from_key&quot;: null,
        &quot;filename&quot;: &quot;et1_first_last.pdf&quot;,
        &quot;checksum&quot;: &quot;ee2714b8b731a8c1e95dffaa33f89728&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;62a7016e-6a82-49fb-b2c6-1bdf3a280d71&quot;,
      &quot;command&quot;: &quot;BuildClaimDetailsFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: null,
        &quot;data_from_key&quot;: &quot;wneo1ogqehw1i8xgimee6xq3vfu4&quot;,
        &quot;filename&quot;: &quot;simple_user_with_rtf.rtf&quot;,
        &quot;checksum&quot;: &quot;e69a0344620b5040b7d0d1595b9c7726&quot;
      }
    }
  ]
}&#39; -X POST \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: c0e8edd7-7ef2-4cd8-a9bb-867a4b2ab630
X-Runtime: 0.046737
Content-Length: 808</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"BuildClaim":{"reference":"222000000300","office":{"name":"London Central","code":22,"telephone":"020 7273 8603","address":"Victory House, 30-34 Kingsway, London WC2B 6EX","email":"londoncentralet@justice.gov.uk"},"pdf_url":"http://localhost:10000/devstoreaccount1/et-api-container/h6xhl96h3ozfjn56aspwyja0minu?sp=r\u0026sv=2016-05-31\u0026se=2019-09-26T12%3A37%3A49Z\u0026rscd=attachment%3B+filename%3D%22et1_first_last.pdf%22%3B+filename*%3DUTF-8%27%27et1_first_last.pdf\u0026sr=b\u0026sig=FS4GHVhd5Mda94uDAzDPbOVTfnDcK63SFjJ3HuZ8TCI%3D"},"BuildPrimaryRespondent":{},"BuildPrimaryClaimant":{},"BuildSecondaryClaimants":{},"BuildSecondaryRespondents":{},"BuildPrimaryRepresentative":{},"BuildPdfFile":{},"BuildClaimDetailsFile":{}},"uuid":"b52445bc-c658-49c6-8940-fa35a0b20f90"}</pre>
