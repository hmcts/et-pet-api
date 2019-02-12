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
  "uuid": "ca53d683-f285-4e87-8e95-5225fa06e0ea",
  "command": "SerialSequence",
  "data": [
    {
      "uuid": "532fd283-3512-45e6-94b1-01073798fa97",
      "command": "BuildClaim",
      "data": {
        "reference": "222000000100",
        "submission_reference": "J704-ZK5E",
        "submission_channel": "Web",
        "case_type": "Single",
        "jurisdiction": "2",
        "office_code": "22",
        "date_of_receipt": "2019-02-12T21:02:35+0000",
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
      "uuid": "15e46869-bd98-45df-841b-ca9bda9d0f2e",
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
      "uuid": "80d8158d-2f5e-49a0-a7b0-eba8c4828e6c",
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
      "uuid": "d04ea2b1-bb09-4339-b314-421ad553fdcf",
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
      "uuid": "3ee0bfee-8bec-4250-8f0b-606da7326c0b",
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
      "uuid": "7080e849-8e3e-4161-9413-a6c6850dac15",
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
      "uuid": "550d3fed-f7de-4bfc-a44c-fbdf56dc419b",
      "command": "BuildPdfFile",
      "data": {
        "data_url": "http://localhost:9000/etapibuckettest/AFbkkyZQ274ZF4LD2XvLcVHs?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&response-content-type=application%2Fpdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=accessKey1%2F20190212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190212T210236Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=949d9068bd615a0ff7d10d81ae1d273367ce3388a0e4341fd28a7e662593cac8",
        "filename": "et1_first_last.pdf",
        "checksum": "ee2714b8b731a8c1e95dffaa33f89728",
        "data_from_key": null
      }
    }
  ]
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/claims/build_claim&quot; -d &#39;{
  &quot;uuid&quot;: &quot;ca53d683-f285-4e87-8e95-5225fa06e0ea&quot;,
  &quot;command&quot;: &quot;SerialSequence&quot;,
  &quot;data&quot;: [
    {
      &quot;uuid&quot;: &quot;532fd283-3512-45e6-94b1-01073798fa97&quot;,
      &quot;command&quot;: &quot;BuildClaim&quot;,
      &quot;data&quot;: {
        &quot;reference&quot;: &quot;222000000100&quot;,
        &quot;submission_reference&quot;: &quot;J704-ZK5E&quot;,
        &quot;submission_channel&quot;: &quot;Web&quot;,
        &quot;case_type&quot;: &quot;Single&quot;,
        &quot;jurisdiction&quot;: &quot;2&quot;,
        &quot;office_code&quot;: &quot;22&quot;,
        &quot;date_of_receipt&quot;: &quot;2019-02-12T21:02:35+0000&quot;,
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
      &quot;uuid&quot;: &quot;15e46869-bd98-45df-841b-ca9bda9d0f2e&quot;,
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
      &quot;uuid&quot;: &quot;80d8158d-2f5e-49a0-a7b0-eba8c4828e6c&quot;,
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
      &quot;uuid&quot;: &quot;d04ea2b1-bb09-4339-b314-421ad553fdcf&quot;,
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
      &quot;uuid&quot;: &quot;3ee0bfee-8bec-4250-8f0b-606da7326c0b&quot;,
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
      &quot;uuid&quot;: &quot;7080e849-8e3e-4161-9413-a6c6850dac15&quot;,
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
      &quot;uuid&quot;: &quot;550d3fed-f7de-4bfc-a44c-fbdf56dc419b&quot;,
      &quot;command&quot;: &quot;BuildPdfFile&quot;,
      &quot;data&quot;: {
        &quot;data_url&quot;: &quot;http://localhost:9000/etapibuckettest/AFbkkyZQ274ZF4LD2XvLcVHs?response-content-disposition=inline%3B%20filename%3D%22et1_first_last.pdf%22%3B%20filename%2A%3DUTF-8%27%27et1_first_last.pdf&amp;response-content-type=application%2Fpdf&amp;X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=accessKey1%2F20190212%2Fus-east-1%2Fs3%2Faws4_request&amp;X-Amz-Date=20190212T210236Z&amp;X-Amz-Expires=300&amp;X-Amz-SignedHeaders=host&amp;X-Amz-Signature=949d9068bd615a0ff7d10d81ae1d273367ce3388a0e4341fd28a7e662593cac8&quot;,
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
X-Request-Id: 119814d4-6d4e-4a58-a390-f4cec231fb67
X-Runtime: 0.327335
Content-Length: 282</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"BuildClaim":{"reference":"222000000100"},"BuildPrimaryRespondent":{},"BuildPrimaryClaimant":{},"BuildSecondaryClaimants":{},"BuildSecondaryRespondents":{},"BuildPrimaryRepresentative":{},"BuildPdfFile":{}},"uuid":"ca53d683-f285-4e87-8e95-5225fa06e0ea"}</pre>
