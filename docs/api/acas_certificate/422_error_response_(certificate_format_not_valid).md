# Acas Certificate API

Acas Certificate Resource

## 422 Error response (certificate format not valid)

### GET /et_acas_api/certificates/:id
### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Etuserid: my_user
Host: example.org
Cookie: </pre>

#### Route

<pre>GET /et_acas_api/certificates/R000201/00/14</pre>

#### Query Parameters

<pre>{
}: </pre>

#### cURL

<pre class="request">curl -g &quot;http://localhost:3000/et_acas_api/certificates/R000201/00/14&quot; -X GET \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Etuserid: my_user&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 04a39f39-bbee-425c-9896-0a31b7491395
X-Runtime: 0.024544
Content-Length: 86</pre>

#### Status

<pre>422 Unprocessable Entity</pre>

#### Body

<pre>{"status":"invalid_certificate_format","errors":{"id":["Invalid certificate format"]}}</pre>
