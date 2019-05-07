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
  "uuid": "15736d0a-054a-460c-8644-61db149b5255",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "uazZKo37yaN8zNQfPmo45eQy",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;15736d0a-054a-460c-8644-61db149b5255&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;uazZKo37yaN8zNQfPmo45eQy&quot;,
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
ETag: W/&quot;1bd760328587e81211c7012271e3edf9&quot;
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 9cdb330d-52a8-41b1-91d5-06f62a98fd71
X-Runtime: 0.075323
Content-Length: 67</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"status":"accepted","uuid":"15736d0a-054a-460c-8644-61db149b5255"}</pre>
