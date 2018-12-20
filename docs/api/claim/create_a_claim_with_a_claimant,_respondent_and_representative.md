# Claim API

A claim is the claim made by the claimant against the respondent (employer)

## Create a claim with a claimant, respondent and representative

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
  "uuid": "932bea42-896d-4da8-89c3-a9d3fd21bcb0",
  "command": "SerialSequence",
  "data": [
    {
      "uuid": "a0462af4-d2bb-4979-99ae-5c4a4f332447",
      "command": "BuildClaim",
      "data": {
        "reference": "222000000100",
        "submission_reference": "J704-ZK5E",
        "submission_channel": "Web",
        "case_type": "Single",
        "jurisdiction": "2",
        "office_code": "22",
        "date_of_receipt": "2018-12-20T12:32:16+0000",
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
      "uuid": "c0791ed5-a095-4bf2-b079-4984b93a1797",
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
      "uuid": "d28ca447-5dd9-48f5-9a26-43b9632a7f88",
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
      "uuid": "60084676-e08c-489e-bf77-d621bd6284e9",
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
      "uuid": "4ea594a1-bf4d-4143-9077-3fc339da919b",
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
      "uuid": "f25242e1-b16a-4048-9f4e-1c2c9724725a",
      "command": "BuildPrimaryRepresentative",
      "data": {
        "name": "Jane Doe",
        "organisation_name": "repco ltd",
        "address_attributes": {
          "building": "Rep Building",
          "street": "Rep Street",
          "locality": "Rep Town",
          "county": "Rep County",
          "post_code": "WC2 2BB"
        },
        "address_telephone_number": "0207 987 6543",
        "mobile_number": "07987654321",
        "representative_type": "Private Individual",
        "dx_number": "dx address",
        "reference": "Rep Ref",
        "contact_preference": "fax",
        "email_address": "",
        "fax_number": "0207 345 6789"
      }
    },
    {
      "uuid": "4dc858c7-b8f7-4cf2-bbe1-304e90c29ca7",
      "command": "BuildPdfFile",
      "data": {
        "data_url": "http://localhost:9000/etapibuckettest/uTXn7aNSsrgo6mzKWHrB2QZC?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&response-content-type=application%2Fpdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=accessKey1%2F20181220%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20181220T123217Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=b69ff71fbe0b5dbabc0f6fdb676db560dd61a08bb42acb38db5023a0f36bc0a8",
        "filename": "et1_first_last.pdf",
        "checksum": "ee2714b8b731a8c1e95dffaa33f89728",
        "data_from_key": null
      }
    }
  ]
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/claims/build_claim&quot; -d &#39;{
  &quot;uuid&quot;: &quot;932bea42-896d-4da8-89c3-a9d3fd21bcb0&quot;,
  &quot;command&quot;: &quot;SerialSequence&quot;,
  &quot;data&quot;: [
    {
      &quot;uuid&quot;: &quot;a0462af4-d2bb-4979-99ae-5c4a4f332447&quot;,
      &quot;command&quot;: &quot;BuildClaim&quot;,
      &quot;data&quot;: {
        &quot;reference&quot;: &quot;222000000100&quot;,
        &quot;submission_reference&quot;: &quot;J704-ZK5E&quot;,
        &quot;submission_channel&quot;: &quot;Web&quot;,
        &quot;case_type&quot;: &quot;Single&quot;,
        &quot;jurisdiction&quot;: &quot;2&quot;,
        &quot;office_code&quot;: &quot;22&quot;,
        &quot;date_of_receipt&quot;: &quot;2018-12-20T12:32:16+0000&quot;,
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
      &quot;uuid&quot;: &quot;c0791ed5-a095-4bf2-b079-4984b93a1797&quot;,
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
      &quot;uuid&quot;: &quot;d28ca447-5dd9-48f5-9a26-43b9632a7f88&quot;,
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
      &quot;uuid&quot;: &quot;60084676-e08c-489e-bf77-d621bd6284e9&quot;,
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
      &quot;uuid&quot;: &quot;4ea594a1-bf4d-4143-9077-3fc339da919b&quot;,
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
      &quot;uuid&quot;: &quot;f25242e1-b16a-4048-9f4e-1c2c9724725a&quot;,
      &quot;command&quot;: &quot;BuildPrimaryRepresentative&quot;,
      &quot;data&quot;: {
        &quot;name&quot;: &quot;Jane Doe&quot;,
        &quot;organisation_name&quot;: &quot;repco ltd&quot;,
        &quot;address_attributes&quot;: {
          &quot;building&quot;: &quot;Rep Building&quot;,
          &quot;street&quot;: &quot;Rep Street&quot;,
          &quot;locality&quot;: &quot;Rep Town&quot;,
          &quot;county&quot;: &quot;Rep County&quot;,
          &quot;post_code&quot;: &quot;WC2 2BB&quot;
        },
        &quot;address_telephone_number&quot;: &quot;0207 987 6543&quot;,
        &quot;mobile_number&quot;: &quot;07987654321&quot;,
        &quot;representative_type&quot;: &quot;Private Individual&quot;,
        &quot;dx_number&quot;: &quot;dx address&quot;,
        &quot;reference&quot;: &quot;Rep Ref&quot;,
        &quot;contact_preference&quot;: &quot;fax&quot;,
        &quot;email_address&quot;: &quot;&quot;,
        &quot;fax_number&quot;: &quot;0207 345 6789&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;4dc858c7-b8f7-4cf2-bbe1-304e90c29ca7&quot;,
      &quot;command&quot;: &quot;BuildPdfFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: &quot;http://localhost:9000/etapibuckettest/uTXn7aNSsrgo6mzKWHrB2QZC?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&amp;response-content-type=application%2Fpdf&amp;X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=accessKey1%2F20181220%2Fus-east-1%2Fs3%2Faws4_request&amp;X-Amz-Date=20181220T123217Z&amp;X-Amz-Expires=300&amp;X-Amz-SignedHeaders=host&amp;X-Amz-Signature=b69ff71fbe0b5dbabc0f6fdb676db560dd61a08bb42acb38db5023a0f36bc0a8&quot;,
        &quot;filename&quot;: &quot;et1_first_last.pdf&quot;,
        &quot;checksum&quot;: &quot;ee2714b8b731a8c1e95dffaa33f89728&quot;,
        &quot;data_from_key&quot;: null
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
X-Request-Id: 1abf9979-a854-4838-9bcd-0519964d3e79
X-Runtime: 0.300356
Content-Length: 248</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"BuildClaim":{"reference":"222000000100"},"BuildPrimaryRespondent":{},"BuildPrimaryClaimant":{},"BuildSecondaryClaimants":{},"BuildSecondaryRespondents":{},"BuildPrimaryRepresentative":{},"BuildPdfFile":{}},"uuid":null}</pre>
