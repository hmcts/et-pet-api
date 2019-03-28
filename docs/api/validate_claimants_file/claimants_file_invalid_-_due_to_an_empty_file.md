# Validate Claimants File API

A service perform validation using various commands

## Claimants file invalid - due to an empty file

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
  "uuid": "1e059ba9-b1b2-4f3f-baf7-db8260008e0c",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "maVEtMPXgZSgCzAjUtwFaU9r",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;1e059ba9-b1b2-4f3f-baf7-db8260008e0c&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;maVEtMPXgZSgCzAjUtwFaU9r&quot;,
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
X-Request-Id: b9c388f9-32b6-4ee5-a52a-0734eb4272b2
X-Runtime: 0.016410
Content-Length: 263</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"1e059ba9-b1b2-4f3f-baf7-db8260008e0c","errors":[{"status":422,"code":"empty_file","title":"file is empty","detail":"file is empty","source":"/base","command":"ValidateClaimantsFile","uuid":"1e059ba9-b1b2-4f3f-baf7-db8260008e0c"}]}</pre>
