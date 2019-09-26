# Validate Claimants File API

A service perform validation using various commands

## Claimants file invalid - due to invalid rows

### POST /api/v2/validate

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | The validation command to perform | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/validate</pre>

#### Body

<pre>{
  "uuid": "eea14395-6c03-41e2-994d-3e088ddfb441",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "brwz9rlww5vec74rbdnn649bk5qm",
    "filename": "simple_user_with_csv_group_claims_multiple_errors.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;eea14395-6c03-41e2-994d-3e088ddfb441&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;brwz9rlww5vec74rbdnn649bk5qm&quot;,
    &quot;filename&quot;: &quot;simple_user_with_csv_group_claims_multiple_errors.csv&quot;,
    &quot;checksum&quot;: &quot;7ac66d9f4af3b498e4cf7b9430974618&quot;
  }
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
X-Request-Id: e88e8bd3-637c-4fbe-a76b-3786f563ae09
X-Runtime: 0.018389
Content-Length: 504</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"eea14395-6c03-41e2-994d-3e088ddfb441","errors":[{"status":422,"code":"invalid","title":"is invalid","detail":"is invalid","source":"/data_from_key/0/date_of_birth","command":"ValidateClaimantsFile","uuid":"eea14395-6c03-41e2-994d-3e088ddfb441"},{"status":422,"code":"inclusion","title":"is not included in the list","detail":"is not included in the list","source":"/data_from_key/1/title","command":"ValidateClaimantsFile","uuid":"eea14395-6c03-41e2-994d-3e088ddfb441"}]}</pre>
