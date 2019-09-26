# Acas Certificate API

Acas Certificate Resource

## 404 Error response (certificate not found)

### GET /et_acas_api/certificates/:id
### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Etuserid: my_user
Host: example.org
Cookie: </pre>

#### Route

<pre>GET /et_acas_api/certificates/R000200/00/14</pre>

#### Query Parameters

<pre>{
}: </pre>

#### cURL

<pre class="request">curl -g &quot;http://localhost:3000/et_acas_api/certificates/R000200/00/14&quot; -X GET \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Etuserid: my_user&quot; \
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
X-Request-Id: 061f903f-d51c-4cff-8513-81f82e61f76e
X-Runtime: 0.017176
Content-Length: 22</pre>

#### Status

<pre>404 Not Found</pre>

#### Body

<pre>{"status":"not_found"}</pre>
