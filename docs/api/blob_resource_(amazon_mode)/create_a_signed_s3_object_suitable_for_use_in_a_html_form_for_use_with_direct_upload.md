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
  "uuid": "97954f49-afe1-4e9b-be47-3b083fb68532",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;97954f49-afe1-4e9b-be47-3b083fb68532&quot;,
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
X-Request-Id: 33b813ae-692b-49bf-8669-abdaed2e299b
X-Runtime: 0.077783
Content-Length: 929</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"amazon"},"uuid":"97954f49-afe1-4e9b-be47-3b083fb68532","data":{"fields":{"key":"direct_uploads/9e02d454-1945-414b-b38d-9142692ea8af","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wNC0yOVQwODozODo0MFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzllMDJkNDU0LTE5NDUtNDE0Yi1iMzhkLTkxNDI2OTJlYThhZiJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDQyOS91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTA0MjlUMDczODQwWiJ9XX0=","x-amz-credential":"accessKey1/20190429/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190429T073840Z","x-amz-signature":"67fddc7537f40837da7afef00189b1db1db177763a537c9cc5839f055d62a32e"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
