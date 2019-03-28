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
  "uuid": "0082e979-5c7c-451f-8376-5d5088a3ba5a",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "22iqceY6c2VdbbXmroRNiZ22",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;0082e979-5c7c-451f-8376-5d5088a3ba5a&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;22iqceY6c2VdbbXmroRNiZ22&quot;,
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

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 0fa8a047-d991-4829-8cc7-ff0cfa110160
X-Runtime: 0.038861
Content-Length: 324</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"0082e979-5c7c-451f-8376-5d5088a3ba5a","errors":[{"status":422,"code":"invalid_columns","title":"file does not contain the correct columns","detail":"file does not contain the correct columns","source":"/base","command":"ValidateClaimantsFile","uuid":"0082e979-5c7c-451f-8376-5d5088a3ba5a"}]}</pre>
