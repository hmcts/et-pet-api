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
  "uuid": "a4accfc1-3c05-4f4a-a511-b8e403ce7721",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;a4accfc1-3c05-4f4a-a511-b8e403ce7721&quot;,
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
X-Request-Id: 81792823-849b-4be1-92bb-add3d9cb2c2f
X-Runtime: 0.023217
Content-Length: 710</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"a4accfc1-3c05-4f4a-a511-b8e403ce7721","data":{"fields":{"key":"direct_uploads/1cc30f7e-8847-4fe8-bb27-a7a967979fe3","permissions":"rw","version":"2016-05-31","expiry":"2019-02-12T23:20:57Z","resource":"b","signature":"Ggyp0OFq9wZlQWcALwC2PhnoKV2iVzUPH8PkUwl3pZY="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/1cc30f7e-8847-4fe8-bb27-a7a967979fe3?sp=rw\u0026sv=2016-05-31\u0026se=2019-02-12T23%3A20%3A57Z\u0026sr=b\u0026sig=Ggyp0OFq9wZlQWcALwC2PhnoKV2iVzUPH8PkUwl3pZY%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/1cc30f7e-8847-4fe8-bb27-a7a967979fe3"}}</pre>
