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
  "uuid": "a3031833-6d14-4cc4-affb-2d7ef65186a3",
  "command": "CreateSignedS3FormData",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/s3/create_signed_url&quot; -d &#39;{
  &quot;uuid&quot;: &quot;a3031833-6d14-4cc4-affb-2d7ef65186a3&quot;,
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
X-Request-Id: 9f5a6dea-84be-402d-83f1-8a0c314532c2
X-Runtime: 0.041038
Content-Length: 904</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"a3031833-6d14-4cc4-affb-2d7ef65186a3","data":{"fields":{"key":"direct_uploads/3e8fd0ba-70e1-44b7-94ce-52c6f76a738b","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMi0xM1QwMDoxNTo1OFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzNlOGZkMGJhLTcwZTEtNDRiNy05NGNlLTUyYzZmNzZhNzM4YiJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDIxMi91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAyMTJUMjMxNTU4WiJ9XX0=","x-amz-credential":"accessKey1/20190212/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190212T231558Z","x-amz-signature":"c93e89cde998f63dd3cf4af97fad6ff3f657415cb0ec3273afe3757284aa04c4"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
