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
  "uuid": "fd628e11-bba9-4623-bb05-cb88eb895cf4",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "TB2xTurAHZs1gfraDNGTKdiR",
    "filename": "simple_user_with_csv_group_claims_multiple_errors.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;fd628e11-bba9-4623-bb05-cb88eb895cf4&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;TB2xTurAHZs1gfraDNGTKdiR&quot;,
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

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 5308c092-5ecd-454d-8a6d-9bfbe86256c9
X-Runtime: 0.065248
Content-Length: 504</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"fd628e11-bba9-4623-bb05-cb88eb895cf4","errors":[{"status":422,"code":"invalid","title":"is invalid","detail":"is invalid","source":"/data_from_key/0/date_of_birth","command":"ValidateClaimantsFile","uuid":"fd628e11-bba9-4623-bb05-cb88eb895cf4"},{"status":422,"code":"inclusion","title":"is not included in the list","detail":"is not included in the list","source":"/data_from_key/1/title","command":"ValidateClaimantsFile","uuid":"fd628e11-bba9-4623-bb05-cb88eb895cf4"}]}</pre>
