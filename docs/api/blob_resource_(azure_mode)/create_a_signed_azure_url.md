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
  "uuid": "f422f221-fb32-4652-8a5f-5515b9b8f363",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;f422f221-fb32-4652-8a5f-5515b9b8f363&quot;,
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
X-Request-Id: 3120b30a-7937-4edb-a0a8-543da3d64cd9
X-Runtime: 0.015269
Content-Length: 710</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"f422f221-fb32-4652-8a5f-5515b9b8f363","data":{"fields":{"key":"direct_uploads/89d75096-cd90-476d-997e-aec2bbc6194c","permissions":"rw","version":"2016-05-31","expiry":"2019-02-20T18:45:22Z","resource":"b","signature":"64eLeSf8EPTYTVoN5tieDLJrEoS4kbdp9Jg1DC5M02w="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/89d75096-cd90-476d-997e-aec2bbc6194c?sp=rw\u0026sv=2016-05-31\u0026se=2019-02-20T18%3A45%3A22Z\u0026sr=b\u0026sig=64eLeSf8EPTYTVoN5tieDLJrEoS4kbdp9Jg1DC5M02w%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/89d75096-cd90-476d-997e-aec2bbc6194c"}}</pre>
