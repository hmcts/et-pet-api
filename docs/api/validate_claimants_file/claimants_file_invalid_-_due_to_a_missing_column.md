# Validate Claimants File API

A service perform validation using various commands

## Claimants file invalid - due to a missing column

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
  "uuid": "b4632b21-0fc9-4271-9e9c-0892f47a0263",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "prrxvx321r8ob3pviuq097haddjs",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;b4632b21-0fc9-4271-9e9c-0892f47a0263&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;prrxvx321r8ob3pviuq097haddjs&quot;,
    &quot;filename&quot;: &quot;simple_user_with_csv_group_claims.csv&quot;,
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
X-Request-Id: 7c481087-c9ef-4867-b1c7-207f58a09449
X-Runtime: 0.013859
Content-Length: 324</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"b4632b21-0fc9-4271-9e9c-0892f47a0263","errors":[{"status":422,"code":"invalid_columns","title":"file does not contain the correct columns","detail":"file does not contain the correct columns","source":"/base","command":"ValidateClaimantsFile","uuid":"b4632b21-0fc9-4271-9e9c-0892f47a0263"}]}</pre>
