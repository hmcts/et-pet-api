# Response API

A response is the response from the employer who the claim is made against.  It comes from the ET3 form

## Response successfully created

### POST /api/v2/respondents/build_response

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | An array of commands to build the response and its various components | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/respondents/build_response</pre>

#### Body

<pre>{
  "uuid": "fcae19fc-4f98-4893-87b8-3a73e44cc334",
  "command": "SerialSequence",
  "data": [
    {
      "uuid": "97a56305-6221-488c-9ae1-5099949c0360",
      "command": "BuildResponse",
      "data": {
        "additional_information_key": null,
        "case_number": "1454321/2017",
        "agree_with_employment_dates": false,
        "defend_claim": true,
        "claimants_name": "Jane Doe",
        "agree_with_early_conciliation_details": false,
        "disagree_conciliation_reason": "lorem ipsum conciliation",
        "employment_start": "2017-01-01",
        "employment_end": "2017-12-31",
        "disagree_employment": "lorem ipsum employment",
        "continued_employment": true,
        "agree_with_claimants_description_of_job_or_title": false,
        "disagree_claimants_job_or_title": "lorem ipsum job title",
        "agree_with_claimants_hours": false,
        "queried_hours": 32.0,
        "agree_with_earnings_details": false,
        "queried_pay_before_tax": 1000.0,
        "queried_pay_before_tax_period": "Monthly",
        "queried_take_home_pay": 900.0,
        "queried_take_home_pay_period": "Monthly",
        "agree_with_claimant_notice": false,
        "disagree_claimant_notice_reason": "lorem ipsum notice reason",
        "agree_with_claimant_pension_benefits": false,
        "disagree_claimant_pension_benefits_reason": "lorem ipsum claimant pension",
        "defend_claim_facts": "lorem ipsum defence",
        "make_employer_contract_claim": true,
        "claim_information": "lorem ipsum info",
        "email_receipt": "email@recei.pt",
        "pdf_template_reference": "et3-v1-en",
        "email_template_reference": "et3-v1-en"
      }
    },
    {
      "uuid": "3b75d9e0-00f9-4ed4-9979-42b114849af6",
      "command": "BuildRespondent",
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
      "uuid": "3ba9a30c-9d0b-4434-b87b-15fa44552435",
      "command": "BuildRepresentative",
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
    }
  ]
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/respondents/build_response&quot; -d &#39;{
  &quot;uuid&quot;: &quot;fcae19fc-4f98-4893-87b8-3a73e44cc334&quot;,
  &quot;command&quot;: &quot;SerialSequence&quot;,
  &quot;data&quot;: [
    {
      &quot;uuid&quot;: &quot;97a56305-6221-488c-9ae1-5099949c0360&quot;,
      &quot;command&quot;: &quot;BuildResponse&quot;,
      &quot;data&quot;: {
        &quot;additional_information_key&quot;: null,
        &quot;case_number&quot;: &quot;1454321/2017&quot;,
        &quot;agree_with_employment_dates&quot;: false,
        &quot;defend_claim&quot;: true,
        &quot;claimants_name&quot;: &quot;Jane Doe&quot;,
        &quot;agree_with_early_conciliation_details&quot;: false,
        &quot;disagree_conciliation_reason&quot;: &quot;lorem ipsum conciliation&quot;,
        &quot;employment_start&quot;: &quot;2017-01-01&quot;,
        &quot;employment_end&quot;: &quot;2017-12-31&quot;,
        &quot;disagree_employment&quot;: &quot;lorem ipsum employment&quot;,
        &quot;continued_employment&quot;: true,
        &quot;agree_with_claimants_description_of_job_or_title&quot;: false,
        &quot;disagree_claimants_job_or_title&quot;: &quot;lorem ipsum job title&quot;,
        &quot;agree_with_claimants_hours&quot;: false,
        &quot;queried_hours&quot;: 32.0,
        &quot;agree_with_earnings_details&quot;: false,
        &quot;queried_pay_before_tax&quot;: 1000.0,
        &quot;queried_pay_before_tax_period&quot;: &quot;Monthly&quot;,
        &quot;queried_take_home_pay&quot;: 900.0,
        &quot;queried_take_home_pay_period&quot;: &quot;Monthly&quot;,
        &quot;agree_with_claimant_notice&quot;: false,
        &quot;disagree_claimant_notice_reason&quot;: &quot;lorem ipsum notice reason&quot;,
        &quot;agree_with_claimant_pension_benefits&quot;: false,
        &quot;disagree_claimant_pension_benefits_reason&quot;: &quot;lorem ipsum claimant pension&quot;,
        &quot;defend_claim_facts&quot;: &quot;lorem ipsum defence&quot;,
        &quot;make_employer_contract_claim&quot;: true,
        &quot;claim_information&quot;: &quot;lorem ipsum info&quot;,
        &quot;email_receipt&quot;: &quot;email@recei.pt&quot;,
        &quot;pdf_template_reference&quot;: &quot;et3-v1-en&quot;,
        &quot;email_template_reference&quot;: &quot;et3-v1-en&quot;
      }
    },
    {
      &quot;uuid&quot;: &quot;3b75d9e0-00f9-4ed4-9979-42b114849af6&quot;,
      &quot;command&quot;: &quot;BuildRespondent&quot;,
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
      &quot;uuid&quot;: &quot;3ba9a30c-9d0b-4434-b87b-15fa44552435&quot;,
      &quot;command&quot;: &quot;BuildRepresentative&quot;,
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
X-Request-Id: c1efa7de-161f-4d9b-924f-b75e9994563e
X-Runtime: 0.141176
Content-Length: 837</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"BuildResponse":{"submitted_at":"2019-02-12T23:15:59.657Z","reference":"142000014000","office_address":"Bristol Civil and Family Justice Centre, 2 Redcliff Street, Bristol, BS1 6GR","office_phone_number":"0117 929 8261","pdf_url":"http://localhost:9000/etapibuckettest/vZiVZXdy7hGrFkcx45gqatJn?response-content-disposition=attachment%3B%20filename%3D%22et3_atos_export.pdf%22%3B%20filename%2A%3DUTF-8%27%27et3_atos_export.pdf\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=accessKey1%2F20190212%2Fus-east-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20190212T231559Z\u0026X-Amz-Expires=3600\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=135fbf37ca0c4ee4529ccf2148ea5bfcfef2c50b2e94030f69d1f6617947a77f"},"BuildRespondent":{},"BuildRepresentative":{}},"uuid":"fcae19fc-4f98-4893-87b8-3a73e44cc334"}</pre>
