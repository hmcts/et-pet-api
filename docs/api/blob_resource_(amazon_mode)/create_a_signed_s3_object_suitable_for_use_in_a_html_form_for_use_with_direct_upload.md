# Blob Resource (Amazon mode) API

Signed Blob resource - amazon mode

## Create a signed s3 object suitable for use in a HTML form for use with direct upload

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
  "uuid": "aee43e3d-700f-4484-8eaa-a0826b193cdc",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;aee43e3d-700f-4484-8eaa-a0826b193cdc&quot;,
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
X-Request-Id: 5d9564b0-22ec-4709-8445-d66d317b7982
X-Runtime: 0.075141
Content-Length: 929</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"amazon"},"uuid":"aee43e3d-700f-4484-8eaa-a0826b193cdc","data":{"fields":{"key":"direct_uploads/84ebb576-65b4-426d-8c08-7ba00ed625a3","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMi0yMFQxOTo0MDoyMloiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzg0ZWJiNTc2LTY1YjQtNDI2ZC04YzA4LTdiYTAwZWQ2MjVhMyJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDIyMC91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAyMjBUMTg0MDIyWiJ9XX0=","x-amz-credential":"accessKey1/20190220/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190220T184022Z","x-amz-signature":"f33a3e51cee3d4b21e975d3f3734e287828a3513ad7c18e2869586a837b41da5"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
