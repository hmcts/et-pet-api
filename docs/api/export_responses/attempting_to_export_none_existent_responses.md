# Export Responses API

Used by the admin to request that a list of responses are exported to an external system such as CCD

## Attempting to export none existent responses

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
  "uuid": "bb86cdc9-9900-4cec-82a3-1355649c00d7",
  "command": "ExportResponses",
  "data": {
    "external_system_id": 43,
    "response_ids": [
      20,
      -1,
      -2
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_responses&quot; -d &#39;{
  &quot;uuid&quot;: &quot;bb86cdc9-9900-4cec-82a3-1355649c00d7&quot;,
  &quot;command&quot;: &quot;ExportResponses&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: 43,
    &quot;response_ids&quot;: [
      20,
      -1,
      -2
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
X-Request-Id: f6f9452e-f4d5-43b3-b375-f7d8a92e3ff8
X-Runtime: 0.009315
Content-Length: 576</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"bb86cdc9-9900-4cec-82a3-1355649c00d7","errors":[{"status":422,"code":"response_not_found","title":"A response with an id of -1 was not found","detail":"A response with an id of -1 was not found","source":"/response_ids","command":"ExportResponses","uuid":"bb86cdc9-9900-4cec-82a3-1355649c00d7"},{"status":422,"code":"response_not_found","title":"A response with an id of -2 was not found","detail":"A response with an id of -2 was not found","source":"/response_ids","command":"ExportResponses","uuid":"bb86cdc9-9900-4cec-82a3-1355649c00d7"}]}</pre>
