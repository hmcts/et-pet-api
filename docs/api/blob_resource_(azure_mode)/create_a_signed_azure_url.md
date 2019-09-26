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
  "uuid": "5cd67c39-a385-4ee7-bc9e-509b8f1c6ad2",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;5cd67c39-a385-4ee7-bc9e-509b8f1c6ad2&quot;,
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

<pre>X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 4437d1ba-de87-4530-b125-cbc25219a583
X-Runtime: 0.046968
Content-Length: 712</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"5cd67c39-a385-4ee7-bc9e-509b8f1c6ad2","data":{"fields":{"key":"direct_uploads/2a76bbec-4c8f-4181-86a4-bd603a4049a8","permissions":"rw","version":"2016-05-31","expiry":"2019-10-06T11:37:48Z","resource":"b","signature":"KakvPRyu9PGZMj8Styz6093vMbNlkocyJb1k2+BWvwc="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/2a76bbec-4c8f-4181-86a4-bd603a4049a8?sp=rw\u0026sv=2016-05-31\u0026se=2019-10-06T11%3A37%3A48Z\u0026sr=b\u0026sig=KakvPRyu9PGZMj8Styz6093vMbNlkocyJb1k2%2BBWvwc%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/2a76bbec-4c8f-4181-86a4-bd603a4049a8"}}</pre>
