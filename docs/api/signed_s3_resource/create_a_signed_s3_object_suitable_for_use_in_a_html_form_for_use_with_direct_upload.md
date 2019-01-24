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
  "uuid": "bf86efd7-d3d9-4ddf-b78e-079b05747705",
  "command": "CreateSignedS3FormData",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/s3/create_signed_url&quot; -d &#39;{
  &quot;uuid&quot;: &quot;bf86efd7-d3d9-4ddf-b78e-079b05747705&quot;,
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
X-Request-Id: 008966a4-8ccd-408c-8330-28fe4bd7816c
X-Runtime: 0.061513
Content-Length: 904</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"bf86efd7-d3d9-4ddf-b78e-079b05747705","data":{"fields":{"key":"direct_uploads/6594cd16-1ddb-4b56-8db4-bb0e0f7766cc","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMS0wOFQxOTowMToyNFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzY1OTRjZDE2LTFkZGItNGI1Ni04ZGI0LWJiMGUwZjc3NjZjYyJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDEwOC91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAxMDhUMTgwMTI0WiJ9XX0=","x-amz-credential":"accessKey1/20190108/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190108T180124Z","x-amz-signature":"27dcb3c6ce781eca169592ab295f2a734e4e155208d3c91aecdab8fe80aa2b9e"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
