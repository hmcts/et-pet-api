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
  "uuid": "e090cbd2-ded4-4fd4-be23-4c17ad77ca07",
  "command": "CreateSignedS3FormData",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/s3/create_signed_url&quot; -d &#39;{
  &quot;uuid&quot;: &quot;e090cbd2-ded4-4fd4-be23-4c17ad77ca07&quot;,
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
X-Request-Id: 774ed1b5-dd6e-4a6e-a4a7-6ba26700bf70
X-Runtime: 0.059836
Content-Length: 904</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"e090cbd2-ded4-4fd4-be23-4c17ad77ca07","data":{"fields":{"key":"direct_uploads/b8a12730-67b9-449f-96cd-7d0e3542fa94","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMi0yMFQxOTo0MDoyM1oiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzL2I4YTEyNzMwLTY3YjktNDQ5Zi05NmNkLTdkMGUzNTQyZmE5NCJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDIyMC91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAyMjBUMTg0MDIzWiJ9XX0=","x-amz-credential":"accessKey1/20190220/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190220T184023Z","x-amz-signature":"cfd01eddd4d74be84a727d0acc3083271b0b3eaa8058111dadcf5bd60d9fe58b"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
