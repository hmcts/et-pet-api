# Export Claims API

Used by the admin to request that a list of claims are exported to an external system such as CCD

## Attempting to export none existent claims

### POST /api/v2/exports/export_claims

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | Contains the data for this command - in this case just the claim_ids and the external_system_id | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/exports/export_claims</pre>

#### Body

<pre>{
  "uuid": "08e1e8bf-6307-4e33-893c-47c04eb8f6fe",
  "command": "ExportClaims",
  "data": {
    "external_system_id": 43,
    "claim_ids": [
      48,
      -1,
      -2
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_claims&quot; -d &#39;{
  &quot;uuid&quot;: &quot;08e1e8bf-6307-4e33-893c-47c04eb8f6fe&quot;,
  &quot;command&quot;: &quot;ExportClaims&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: 43,
    &quot;claim_ids&quot;: [
      48,
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
X-Request-Id: d1b79a31-8521-4cbb-8d1e-3a4c073aad8a
X-Runtime: 0.009899
Content-Length: 546</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"08e1e8bf-6307-4e33-893c-47c04eb8f6fe","errors":[{"status":422,"code":"claim_not_found","title":"A claim with an id of -1 was not found","detail":"A claim with an id of -1 was not found","source":"/claim_ids","command":"ExportClaims","uuid":"08e1e8bf-6307-4e33-893c-47c04eb8f6fe"},{"status":422,"code":"claim_not_found","title":"A claim with an id of -2 was not found","detail":"A claim with an id of -2 was not found","source":"/claim_ids","command":"ExportClaims","uuid":"08e1e8bf-6307-4e33-893c-47c04eb8f6fe"}]}</pre>
