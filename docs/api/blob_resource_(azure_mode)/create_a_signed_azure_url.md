# Blob Resource (Azure mode) API

Signed Blob resource - azure mode

## Create a signed azure url

### POST /api/v2/build_blob

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | No data is required for this command | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/build_blob</pre>

#### Body

<pre>{
  "uuid": "0ae81de7-7a64-4b51-bfa1-5ce6784bb952",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;0ae81de7-7a64-4b51-bfa1-5ce6784bb952&quot;,
  &quot;command&quot;: &quot;BuildBlob&quot;,
  &quot;data&quot;: null,
  &quot;async&quot;: false
}&#39; -X POST \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 71e68c25-8e05-4492-923e-6ac483d5015c
X-Runtime: 0.022352
Content-Length: 714</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"0ae81de7-7a64-4b51-bfa1-5ce6784bb952","data":{"fields":{"key":"direct_uploads/7375a41c-8e1e-48f1-9e52-0d8b96345a6f","permissions":"rw","version":"2016-05-31","expiry":"2019-04-29T07:43:41Z","resource":"b","signature":"z/9DRuz7kejjJ4c2gzZvzos+4hooywztUcGXBZqgD3w="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/7375a41c-8e1e-48f1-9e52-0d8b96345a6f?sp=rw\u0026sv=2016-05-31\u0026se=2019-04-29T07%3A43%3A41Z\u0026sr=b\u0026sig=z%2F9DRuz7kejjJ4c2gzZvzos%2B4hooywztUcGXBZqgD3w%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/7375a41c-8e1e-48f1-9e52-0d8b96345a6f"}}</pre>
