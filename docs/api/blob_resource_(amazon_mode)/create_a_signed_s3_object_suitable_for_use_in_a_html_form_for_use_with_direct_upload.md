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
  "uuid": "a7708bb7-9712-474f-bfba-1454bb1821e4",
  "command": "BuildBlob",
  "data": null,
  "async": false
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/build_blob&quot; -d &#39;{
  &quot;uuid&quot;: &quot;a7708bb7-9712-474f-bfba-1454bb1821e4&quot;,
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
X-Request-Id: b99bf5c4-13b1-48c4-b19c-4a414d7235db
X-Runtime: 0.055107
Content-Length: 929</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{"cloud_provider":"amazon"},"uuid":"a7708bb7-9712-474f-bfba-1454bb1821e4","data":{"fields":{"key":"direct_uploads/5902753a-6fad-4e59-9fb4-e677b7d140f6","success_action_status":"201","policy":"eyJleHBpcmF0aW9uIjoiMjAxOS0wMy0yOFQxNDo1OTozN1oiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJldGFwaWRpcmVjdGJ1Y2tldHRlc3QifSx7ImtleSI6ImRpcmVjdF91cGxvYWRzLzU5MDI3NTNhLTZmYWQtNGU1OS05ZmI0LWU2NzdiN2QxNDBmNiJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNzS2V5MS8yMDE5MDMyOC91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxOTAzMjhUMTM1OTM3WiJ9XX0=","x-amz-credential":"accessKey1/20190328/us-east-1/s3/aws4_request","x-amz-algorithm":"AWS4-HMAC-SHA256","x-amz-date":"20190328T135937Z","x-amz-signature":"405a98e42c48ddd7b204ef3e13d2e00e53071f5d3fdc96c5254872a7225d3992"},"url":"http://localhost:9000/etapidirectbuckettest"}}</pre>
