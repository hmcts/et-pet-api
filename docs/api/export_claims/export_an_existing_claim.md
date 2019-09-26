# Export Claims API

Used by the admin to request that a list of claims are exported to an external system such as CCD

## Export an existing claim

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
  "uuid": "b7c322be-053b-461b-8e38-dbe471b2a507",
  "command": "ExportClaims",
  "data": {
    "external_system_id": 43,
    "claim_ids": [
      46
    ]
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/exports/export_claims&quot; -d &#39;{
  &quot;uuid&quot;: &quot;b7c322be-053b-461b-8e38-dbe471b2a507&quot;,
  &quot;command&quot;: &quot;ExportClaims&quot;,
  &quot;data&quot;: {
    &quot;external_system_id&quot;: 43,
    &quot;claim_ids&quot;: [
      46
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
X-Request-Id: 71f485ac-ce80-4bd5-8956-c7e0b8bb7a5c
X-Runtime: 0.019679
Content-Length: 77</pre>

#### Status

<pre>202 Accepted</pre>

#### Body

<pre>{"status":"accepted","meta":{},"uuid":"b7c322be-053b-461b-8e38-dbe471b2a507"}</pre>
