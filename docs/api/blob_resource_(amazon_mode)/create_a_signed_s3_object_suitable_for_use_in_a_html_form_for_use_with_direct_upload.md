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
  "uuid": "b2d7a503-36e0-4a1c-8b85-653524d95cce",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;b2d7a503-36e0-4a1c-8b85-653524d95cce&quot;,
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
X-Request-Id: 648a4ca3-b506-426e-a237-80b728293a5a
X-Runtime: 0.082247
Content-Length: 929</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"amazon"},"uuid":"b2d7a503-36e0-4a1c-8b85-653524d95cce","data":{"fields":{"key":"direct_uploads/d9995b9b-4ddc-4fa0-b2db-ae90b43297ec","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMy0yMVQxODo0NzoxMVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzL2Q5OTk1YjliLTRkZGMtNGZhMC1iMmRiLWFlOTBiNDMyOTdlYyJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDMyMS91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAzMjFUMTc0NzExWiJ9XX0=","x-amz-credential":"accessKey1/20190321/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190321T174711Z","x-amz-signature":"eea97e25a16cbb204784a70f28606f67d6ea7fb2b5f34916af9d0281b57ca922"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
