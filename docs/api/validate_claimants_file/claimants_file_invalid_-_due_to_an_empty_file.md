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
  "uuid": "c9f82c91-2b93-4474-95de-dbd8f9921c44",
  "command": "ValidateClaimantsFile",
  "data": {
    "data_url": null,
    "data_from_key": "K11VbGzbC4p8vPdSwHHvE3fy",
    "filename": "simple_user_with_csv_group_claims.csv",
    "checksum": "7ac66d9f4af3b498e4cf7b9430974618"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/validate&quot; -d &#39;{
  &quot;uuid&quot;: &quot;c9f82c91-2b93-4474-95de-dbd8f9921c44&quot;,
  &quot;command&quot;: &quot;ValidateClaimantsFile&quot;,
  &quot;data&quot;: {
    &quot;data_url&quot;: null,
    &quot;data_from_key&quot;: &quot;K11VbGzbC4p8vPdSwHHvE3fy&quot;,
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
X-Request-Id: 6c04dcd5-7638-4c61-a72f-137d0ddb56d6
X-Runtime: 0.040682
Content-Length: 263</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"c9f82c91-2b93-4474-95de-dbd8f9921c44","errors":[{"status":422,"code":"empty_file","title":"file is empty","detail":"file is empty","source":"/base","command":"ValidateClaimantsFile","uuid":"c9f82c91-2b93-4474-95de-dbd8f9921c44"}]}</pre>
