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
  "uuid": "59e943f7-d58b-4b88-8516-910840ea7e4e",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;59e943f7-d58b-4b88-8516-910840ea7e4e&quot;,
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
X-Request-Id: e01ee76f-6131-4b6b-9527-37a8151ab0ff
X-Runtime: 0.018129
Content-Length: 712</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"azure"},"uuid":"59e943f7-d58b-4b88-8516-910840ea7e4e","data":{"fields":{"key":"direct_uploads/d9754978-a216-40a2-98c6-e9eda5d3b31b","permissions":"rw","version":"2016-05-31","expiry":"2019-03-21T17:52:11Z","resource":"b","signature":"erS66wlTbZjgaDNn3cjJYIFxIdNrwXWhss+3oEf6DRc="},"url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/d9754978-a216-40a2-98c6-e9eda5d3b31b?sp=rw\u0026sv=2016-05-31\u0026se=2019-03-21T17%3A52%3A11Z\u0026sr=b\u0026sig=erS66wlTbZjgaDNn3cjJYIFxIdNrwXWhss%2B3oEf6DRc%3D","unsigned_url":"http://localhost:10000/devstoreaccount1/et-api-direct-container/direct_uploads/d9754978-a216-40a2-98c6-e9eda5d3b31b"}}</pre>
