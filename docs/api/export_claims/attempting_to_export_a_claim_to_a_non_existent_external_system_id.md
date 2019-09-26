# Export Claims API

Used by the admin to request that a list of claims are exported to an external system such as CCD

## Attempting to export a claim to a non existent external system id

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
  "uuid": "d5d28778-a047-4931-8992-19ba160061f1",
  "command": "ExportClaims",
  "data": {
    "external_system_id": -1,
    "claim_ids": [
      47
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_claims&quot; -d &#39;{
  &quot;uuid&quot;: &quot;d5d28778-a047-4931-8992-19ba160061f1&quot;,
  &quot;command&quot;: &quot;ExportClaims&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: -1,
    &quot;claim_ids&quot;: [
      47
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
X-Request-Id: 669ed087-2f0e-4226-922f-7c9678e27b20
X-Runtime: 0.007458
Content-Length: 357</pre>

#### Status

<pre>400 Bad Request</pre>

#### Body

<pre>{"status":"not_accepted","uuid":"d5d28778-a047-4931-8992-19ba160061f1","errors":[{"status":422,"code":"external_system_not_found","title":"The external system with an id of -1 was not found","detail":"The external system with an id of -1 was not found","source":"/external_system_id","command":"ExportClaims","uuid":"d5d28778-a047-4931-8992-19ba160061f1"}]}</pre>
