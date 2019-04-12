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
  "uuid": "91ac28e6-edaf-41f5-9558-7ee92eb7da44",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;91ac28e6-edaf-41f5-9558-7ee92eb7da44&quot;,
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
X-Request-Id: ac5dd625-8528-428f-82b3-72875acb7ee3
X-Runtime: 0.017840
Content-Length: 712</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"91ac28e6-edaf-41f5-9558-7ee92eb7da44","data":{"fields":{"key":"direct_uploads/7d0c3626-4416-4e40-a485-7b732c0ac0e6","permissions":"rw","version":"2016-05-31","expiry":"2019-03-28T14:04:37Z","resource":"b","signature":"dEMG7PCCqKiJtA79Ge6a7+bN1hepRHgezgxjNQ9iRhE="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/7d0c3626-4416-4e40-a485-7b732c0ac0e6?sp=rw\u0026sv=2016-05-31\u0026se=2019-03-28T14%3A04%3A37Z\u0026sr=b\u0026sig=dEMG7PCCqKiJtA79Ge6a7%2BbN1hepRHgezgxjNQ9iRhE%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/7d0c3626-4416-4e40-a485-7b732c0ac0e6"}}</pre>
