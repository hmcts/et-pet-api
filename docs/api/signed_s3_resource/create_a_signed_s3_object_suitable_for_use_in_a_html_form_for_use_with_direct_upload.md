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
  "uuid": "6e2c276e-bfc9-4ab2-b3d5-8a0367391db6",
  "command": "CreateSignedS3FormData",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/s3/create_signed_url&quot; -d &#39;{
  &quot;uuid&quot;: &quot;6e2c276e-bfc9-4ab2-b3d5-8a0367391db6&quot;,
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
X-Request-Id: e08664cd-a88f-42ac-a1bb-7ddd87c870a7
X-Runtime: 0.026277
Content-Length: 904</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"6e2c276e-bfc9-4ab2-b3d5-8a0367391db6","data":{"fields":{"key":"direct_uploads/10606769-d6eb-4703-9149-7c492220731a","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMy0yOFQxNDo1OTozOVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzEwNjA2NzY5LWQ2ZWItNDcwMy05MTQ5LTdjNDkyMjIwNzMxYSJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDMyOC91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAzMjhUMTM1OTM5WiJ9XX0=","x-amz-credential":"accessKey1/20190328/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190328T135939Z","x-amz-signature":"5572f003323fbccefe0b2a9fb0601da2b6b179171f8c747e3ee14082c619ea91"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
