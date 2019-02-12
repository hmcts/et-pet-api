# Diversity response API

Diversity response resource

## Create a diversity response

### POST /api/v2/diversity/build_diversity_response

### Parameters

| Name | Description | Required | Scope |
|------|-------------|----------|-------|
| uuid | A unique ID produced by the client to refer to this command | false |  |
| data | The diversity response data | false |  |
| command |  command | false |  |

### Request

#### Headers

<pre>Content-Type: application/json
Accept: application/json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST /api/v2/diversity/build_diversity_response</pre>

#### Body

<pre>{
  "uuid": "19ab009a-2808-43be-824d-01e5b2d107c0",
  "command": "BuildDiversityResponse",
  "data": {
    "claim_type": "Discrimination",
    "sex": "Prefer not to say",
    "sexual_identity": "Gay / Lesbian",
    "age_group": "35-44",
    "ethnicity": "Black / African / Caribbean / Black British",
    "ethnicity_subgroup": "Any other Black / African / Caribbean background",
    "disability": "No",
    "caring_responsibility": "Prefer not to say",
    "gender": "Prefer not to say",
    "gender_at_birth": "Prefer not to say",
    "pregnancy": "Prefer not to say",
    "relationship": "Divorced",
    "religion": "Prefer not to say"
  }
}</pre>

#### cURL

<pre class="request">curl &quot;http://localhost:3000/api/v2/diversity/build_diversity_response&quot; -d &#39;{
  &quot;uuid&quot;: &quot;19ab009a-2808-43be-824d-01e5b2d107c0&quot;,
  &quot;command&quot;: &quot;BuildDiversityResponse&quot;,
  &quot;data&quot;: {
    &quot;claim_type&quot;: &quot;Discrimination&quot;,
    &quot;sex&quot;: &quot;Prefer not to say&quot;,
    &quot;sexual_identity&quot;: &quot;Gay / Lesbian&quot;,
    &quot;age_group&quot;: &quot;35-44&quot;,
    &quot;ethnicity&quot;: &quot;Black / African / Caribbean / Black British&quot;,
    &quot;ethnicity_subgroup&quot;: &quot;Any other Black / African / Caribbean background&quot;,
    &quot;disability&quot;: &quot;No&quot;,
    &quot;caring_responsibility&quot;: &quot;Prefer not to say&quot;,
    &quot;gender&quot;: &quot;Prefer not to say&quot;,
    &quot;gender_at_birth&quot;: &quot;Prefer not to say&quot;,
    &quot;pregnancy&quot;: &quot;Prefer not to say&quot;,
    &quot;relationship&quot;: &quot;Divorced&quot;,
    &quot;religion&quot;: &quot;Prefer not to say&quot;
  }
}&#39; -X POST \
	-H &quot;Content-Type: application/json&quot; \
	-H &quot;Accept: application/json&quot; \
	-H &quot;Host: example.org&quot; \
	-H &quot;Cookie: &quot;</pre>

### Response

#### Headers

<pre>Content-Type: application/json; charset=utf-8
ETag: W/&quot;ff718889922a654bd0d721815f8e1c32&quot;
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 434a53d8-f565-4391-8f50-132a2c85ec93
X-Runtime: 0.045770
Content-Length: 67</pre>

#### Status

<pre>201 Created</pre>

#### Body

<pre>{"status":"accepted","uuid":"19ab009a-2808-43be-824d-01e5b2d107c0"}</pre>
