# Claim Reference API

Claim Reference resource

## Create a reference number based on post code

### POST /api/v2/references/create_reference

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | The command data containing the post code | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/references/create_reference</pre>

#### Body

<pre>{
  "uuid": "123279fb-872e-4ee0-a600-2eebed1251e2",
  "command": "CreateReference",
  "async": false,
  "data": {
    "post_code": "SW1H 209ST"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/references/create_reference&quot; -d &#39;{
  &quot;uuid&quot;: &quot;123279fb-872e-4ee0-a600-2eebed1251e2&quot;,
  &quot;command&quot;: &quot;CreateReference&quot;,
  &quot;async&quot;: false,
  &quot;data&quot;: {
    &quot;post_code&quot;: &quot;SW1H 209ST&quot;
  }
}&#39; -X POST \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>Content-Type: application/json; charset=utf-8
ETag: W/&quot;645b15e60ed7bc50b59e746d3a8a899e&quot;
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 9e3356f3-ce55-4d64-bad6-e9aefa7f4728
X-Runtime: 0.042785
Content-Length: 246</pre>

#### Status

<pre>201 Created</pre>

#### Body

<pre>{"status":"created","meta":{},"uuid":"123279fb-872e-4ee0-a600-2eebed1251e2","data":{"reference":"222000013700","office":{"code":"22","name":"London Central","address":"Victory House, 30-34 Kingsway, London WC2B 6EX","telephone":"020 7273 8603"}}}</pre>
