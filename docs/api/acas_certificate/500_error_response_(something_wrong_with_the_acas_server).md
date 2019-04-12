# Acas Certificate API

Acas Certificate Resource

## 500 Error response (something wrong with the ACAS server)

### GET /et_acas_api/certificates/:id
### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Etuserid: my_user
Host: example.org
Cookie: </pre>

#### Route

<pre>GET /et_acas_api/certificates/R000500/00/14</pre>

#### Query Parameters

<pre>{
}: </pre>

#### cURL

<pre class="request">curl -g &quot;http://localhost:3000/et_acas_api/certificates/R000500/00/14&quot; -X GET \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Etuserid: my_user&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 05298e0d-095a-49e4-b825-13576a3b6e87
X-Runtime: 0.029221
Content-Length: 89</pre>

#### Status

<pre>500 Internal Server Error</pre>

#### Body

<pre>{"status":"acas_server_error","errors":{"base":["An error occured in the ACAS service"]}}</pre>
