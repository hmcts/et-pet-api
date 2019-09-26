# Validate Claimants File API

A service perform validation using various commands

## Claimants file invalid - due to a missing file

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
  "uuid": "4a6c0c15-6690-4a34-a204-d5fc971fa9f0",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "wrongvalue",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;4a6c0c15-6690-4a34-a204-d5fc971fa9f0&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;wrongvalue&quot;,
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
X-Request-Id: 7824e902-6f41-47dd-b89f-3d3fb6e5cdf7
X-Runtime: 0.006488
Content-Length: 269</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"4a6c0c15-6690-4a34-a204-d5fc971fa9f0","errors":[{"status":422,"code":"missing_file","title":"file is missing","detail":"file is missing","source":"/base","command":"ValidateClaimantsFile","uuid":"4a6c0c15-6690-4a34-a204-d5fc971fa9f0"}]}</pre>
