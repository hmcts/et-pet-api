# Export Responses API

Used by the admin to request that a list of responses are exported to an external system such as CCD

## Export an existing response

### POST /api/v2/exports/export_responses

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | Contains the data for this command - in this case just the response_ids and the external_system_id | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/exports/export_responses</pre>

#### Body

<pre>{
  "uuid": "fea4decf-2efe-4cd6-96b3-f0a4bbeeca78",
  "command": "ExportResponses",
  "data": {
    "external_system_id": 43,
    "response_ids": [
      18
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_responses&quot; -d &#39;{
  &quot;uuid&quot;: &quot;fea4decf-2efe-4cd6-96b3-f0a4bbeeca78&quot;,
  &quot;command&quot;: &quot;ExportResponses&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: 43,
    &quot;response_ids&quot;: [
      18
    ]
  }
}&#39; -X POST \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 50e03801-3aba-4aa0-9e74-3087e7325998
X-Runtime: 0.019560
Content-Length: 77</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"fea4decf-2efe-4cd6-96b3-f0a4bbeeca78"}</pre>
