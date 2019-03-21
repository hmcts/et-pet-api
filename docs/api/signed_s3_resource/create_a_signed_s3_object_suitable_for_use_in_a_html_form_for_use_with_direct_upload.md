# Signed S3 Resource API

Signed S3 resource

## Create a signed s3 object suitable for use in a HTML form for use with direct upload

### POST /api/v2/s3/create_signed_url

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

<pre>POST /api/v2/s3/create_signed_url</pre>

#### Body

<pre>{
  "uuid": "4561101a-b453-4b60-94dd-b16aa674e835",
  "command": "CreateSignedS3FormData",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/s3/create_signed_url&quot; -d &#39;{
  &quot;uuid&quot;: &quot;4561101a-b453-4b60-94dd-b16aa674e835&quot;,
  &quot;command&quot;: &quot;CreateSignedS3FormData&quot;,
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
X-Request-Id: 9d105904-aa13-4b48-8b94-245a4dc7366b
X-Runtime: 0.041212
Content-Length: 904</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"4561101a-b453-4b60-94dd-b16aa674e835","data":{"fields":{"key":"direct_uploads/3d32d157-eb07-4ec1-b55d-590b158e86f6","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMy0yMVQxODo0NzoxM1oiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzNkMzJkMTU3LWViMDctNGVjMS1iNTVkLTU5MGIxNThlODZmNiJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDMyMS91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAzMjFUMTc0NzEzWiJ9XX0=","x-amz-credential":"accessKey1/20190321/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190321T174713Z","x-amz-signature":"e5a3e1953bc5d94b609aefafecafcdeab2e71450c3ab2865feb57710313a589e"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
