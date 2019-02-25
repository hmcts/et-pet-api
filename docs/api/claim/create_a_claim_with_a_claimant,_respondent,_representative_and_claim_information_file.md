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
  "uuid": "bffe1e96-346c-46c4-848d-21d3211eac19",
  "command": "SerialSequence",
  "data": [
    {
      "uuid": "4ba5d01c-c398-4ce7-93a7-a67b7ad925bf",
      "command": "BuildClaim",
      "data": {
        "reference": "222000000200",
        "submission_reference": "J704-ZK5E",
        "submission_channel": "Web",
        "case_type": "Single",
        "jurisdiction": "2",
        "office_code": "22",
        "date_of_receipt": "2019-02-20T18:40:23+0000",
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
        "employment_details": {
        },
        "is_unfair_dismissal": false
      }
    },
    {
      "uuid": "22a98a4b-32bf-4b36-b316-4cc72bbd3936",
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
      "uuid": "6806f7db-bfc2-47bf-bb7e-c03ab0a2061e",
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
          "post_code": "SW1H 9AJ"
        },
        "address_telephone_number": "01234 567890",
        "mobile_number": "01234 098765",
        "email_address": "test@digital.justice.gov.uk",
        "fax_number": null,
        "contact_preference": "email",
        "gender": "Male",
        "date_of_birth": "1982-11-21",
        "special_needs": null
      }
    },
    {
      "uuid": "190f2e14-ae15-4958-a136-917a3176fde9",
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
          "contact_preference": "email",
          "gender": "Male",
          "date_of_birth": "1982-11-21",
          "special_needs": null
        }
      ]
    },
    {
      "uuid": "55f2b4bc-3063-45fc-8c30-fb79c6b586f8",
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
      "uuid": "0389f32a-48d9-4cc8-ba99-4c735c051e56",
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
      "uuid": "e1e7b459-3719-428c-a229-dee9dc2aaa02",
      "command": "BuildPdfFile",
      "data": {
        "data_url": "http://localhost:9000/etapibuckettest/CDsshEkwWmLrRB11iP2RUZgg?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&response-content-type=application%2Fpdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=accessKey1%2F20190220%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190220T184023Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=ae6ba594eb81a112bf42fd8af7e72b526adf43fb6697926999717b1e39a6070a",
        "data_from_key": null,
        "filename": "et1_first_last.pdf",
        "checksum": "ee2714b8b731a8c1e95dffaa33f89728"
      }
    },
    {
      "uuid": "0b37004d-1e5c-4851-8d5f-b2623eadc832",
      "command": "BuildClaimDetailsFile",
      "data": {
        "data_url": null,
        "data_from_key": "wiLihi8r3YjytnNUzd836R4y",
        "filename": "simple_user_with_rtf.rtf",
        "checksum": "e69a0344620b5040b7d0d1595b9c7726"
      }
    }
  ]
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/claims/build_claim&quot; -d &#39;{
  &quot;uuid&quot;: &quot;bffe1e96-346c-46c4-848d-21d3211eac19&quot;,
  &quot;command&quot;: &quot;SerialSequence&quot;,
  &quot;data&quot;: [
    {
      &quot;uuid&quot;: &quot;4ba5d01c-c398-4ce7-93a7-a67b7ad925bf&quot;,
      &quot;command&quot;: &quot;BuildClaim&quot;,
      &quot;data&quot;: {
        &quot;reference&quot;: &quot;222000000200&quot;,
        &quot;submission_reference&quot;: &quot;J704-ZK5E&quot;,
        &quot;submission_channel&quot;: &quot;Web&quot;,
        &quot;case_type&quot;: &quot;Single&quot;,
        &quot;jurisdiction&quot;: &quot;2&quot;,
        &quot;office_code&quot;: &quot;22&quot;,
        &quot;date_of_receipt&quot;: &quot;2019-02-20T18:40:23+0000&quot;,
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
        &quot;employment_details&quot;: {
        },
        &quot;is_unfair_dismissal&quot;: false
      }
    },
    {
      &quot;uuid&quot;: &quot;22a98a4b-32bf-4b36-b316-4cc72bbd3936&quot;,
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
      &quot;uuid&quot;: &quot;6806f7db-bfc2-47bf-bb7e-c03ab0a2061e&quot;,
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
          &quot;post_code&quot;: &quot;SW1H 9AJ&quot;
        },
        &quot;address_telephone_number&quot;: &quot;01234 567890&quot;,
        &quot;mobile_number&quot;: &quot;01234 098765&quot;,
        &quot;email_address&quot;: &quot;test@digital.justice.gov.uk&quot;,
        &quot;fax_number&quot;: null,
        &quot;contact_preference&quot;: &quot;email&quot;,
        &quot;gender&quot;: &quot;Male&quot;,
        &quot;date_of_birth&quot;: &quot;1982-11-21&quot;,
        &quot;special_needs&quot;: null
      }
    },
    {
      &quot;uuid&quot;: &quot;190f2e14-ae15-4958-a136-917a3176fde9&quot;,
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
          &quot;contact_preference&quot;: &quot;email&quot;,
          &quot;gender&quot;: &quot;Male&quot;,
          &quot;date_of_birth&quot;: &quot;1982-11-21&quot;,
          &quot;special_needs&quot;: null
        }
      ]
    },
    {
      &quot;uuid&quot;: &quot;55f2b4bc-3063-45fc-8c30-fb79c6b586f8&quot;,
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
      &quot;uuid&quot;: &quot;0389f32a-48d9-4cc8-ba99-4c735c051e56&quot;,
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
      &quot;uuid&quot;: &quot;e1e7b459-3719-428c-a229-dee9dc2aaa02&quot;,
      &quot;command&quot;: &quot;BuildPdfFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: &quot;http://localhost:9000/etapibuckettest/CDsshEkwWmLrRB11iP2RUZgg?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&amp;response-content-type=application%2Fpdf&amp;X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=accessKey1%2F20190220%2Fus-east-1%2Fs3%2Faws4_request&amp;X-Amz-Date=20190220T184023Z&amp;X-Amz-Expires=300&amp;X-Amz-SignedHeaders=host&amp;X-Amz-Signature=ae6ba594eb81a112bf42fd8af7e72b526adf43fb6697926999717b1e39a6070a&quot;,
        &quot;data_from_key&quot;: null,
        &quot;filename&quot;: &quot;et1_first_last.pdf&quot;,
        &quot;checksum&quot;: &quot;ee2714b8b731a8c1e95dffaa33f89728&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;0b37004d-1e5c-4851-8d5f-b2623eadc832&quot;,
      &quot;command&quot;: &quot;BuildClaimDetailsFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: null,
        &quot;data_from_key&quot;: &quot;wiLihi8r3YjytnNUzd836R4y&quot;,
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

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 6cada59e-450e-4f34-b986-dcff23a4397e
X-Runtime: 0.258629
Content-Length: 309</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"BuildClaim":{"reference":"222000000200"},"BuildPrimaryRespondent":{},"BuildPrimaryClaimant":{},"BuildSecondaryClaimants":{},"BuildSecondaryRespondents":{},"BuildPrimaryRepresentative":{},"BuildPdfFile":{},"BuildClaimDetailsFile":{}},"uuid":"bffe1e96-346c-46c4-848d-21d3211eac19"}</pre>
