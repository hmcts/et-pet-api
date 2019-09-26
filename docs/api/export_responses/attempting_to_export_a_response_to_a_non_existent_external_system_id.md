# Export Responses API

Used by the admin to request that a list of responses are exported to an external system such as CCD

## Attempting to export a response to a non existent external system id

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
  "uuid": "9f6e3de8-e731-4b7e-9f10-69e9e70e200b",
  "command": "ExportResponses",
  "data": {
    "external_system_id": -1,
    "response_ids": [
      19
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_responses&quot; -d &#39;{
  &quot;uuid&quot;: &quot;9f6e3de8-e731-4b7e-9f10-69e9e70e200b&quot;,
  &quot;command&quot;: &quot;ExportResponses&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: -1,
    &quot;response_ids&quot;: [
      19
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
X-Request-Id: af0fc569-d3f7-4425-aab8-69308630feb6
X-Runtime: 0.007150
Content-Length: 360</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"9f6e3de8-e731-4b7e-9f10-69e9e70e200b","errors":[{"status":422,"code":"external_system_not_found","title":"The external system with an id of -1 was not found","detail":"The external system with an id of -1 was not found","source":"/external_system_id","command":"ExportResponses","uuid":"9f6e3de8-e731-4b7e-9f10-69e9e70e200b"}]}</pre>
