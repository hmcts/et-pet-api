# Validate Claimants File API

A service perform validation using various commands

## Claimants file successfully validated

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
  "uuid": "ead87c27-67f0-4559-96c7-432419b7d40b",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "hhlf03s9tmrhnqipczlanz6p0oqj",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;ead87c27-67f0-4559-96c7-432419b7d40b&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;hhlf03s9tmrhnqipczlanz6p0oqj&quot;,
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
ETag: W/&quot;a4e22d5a1f6a315b76f1bbf249b5cfad&quot;
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 486cc6fe-a925-4d42-93c1-a702138a6d68
X-Runtime: 0.025940
Content-Length: 67</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"status":"accepted","uuid":"ead87c27-67f0-4559-96c7-432419b7d40b"}</pre>
