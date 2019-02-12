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
  "uuid": "d158344c-50d0-4f5a-a356-77a11a1d6fb9",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;d158344c-50d0-4f5a-a356-77a11a1d6fb9&quot;,
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
X-Request-Id: c3ff8b59-b571-441e-b5b7-e8cca6284195
X-Runtime: 0.070015
Content-Length: 929</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"amazon"},"uuid":"d158344c-50d0-4f5a-a356-77a11a1d6fb9","data":{"fields":{"key":"direct_uploads/4f4af600-5c76-4602-8ef6-110428af1eb5","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMi0xM1QwMDoxNTo1N1oiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzRmNGFmNjAwLTVjNzYtNDYwMi04ZWY2LTExMDQyOGFmMWViNSJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDIxMi91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAyMTJUMjMxNTU3WiJ9XX0=","x-amz-credential":"accessKey1/20190212/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190212T231557Z","x-amz-signature":"f02efaf9a26e398cea6b7aaa1c62f196d7e382b8957e4fd870350f601b500b77"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
