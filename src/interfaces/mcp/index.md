# MCP

Spectre Scan ships a [Model Context Protocol][mcp] server so an AI client
(Claude Desktop / Code, Cursor, Continue — anything that speaks MCP) can
drive scans directly: spawn an _Instance_, watch its progress, fetch
issues and reports, and tear it down again — over a single HTTP endpoint.

The full surface is exposed as MCP _tools_, _prompts_, and _resources_,
and described to the client via the protocol's own discovery calls
(`tools/list`, `prompts/list`, `resources/list`). Whatever the model
sees in its context is exactly what the surface advertises — the
descriptions _are_ the docs.

This page is the canonical reference. It is the only document an AI
needs to understand and drive the surface end to end; everything else
in this section either complements it or provides language bindings.

[mcp]: https://modelcontextprotocol.io/

## Table of contents

- [Server](#server)
- [Endpoint](#endpoint)
- [Tools](#tools)
- [Prompts](#prompts)
- [Resources](#resources)
- [Options reference](#options-reference)
- [Auth](#auth)
- [Self-discovery flow](#self-discovery-flow)
- [Status semantics](#status-semantics)
- [Live events](#live-events)
- [Polling cadence](#polling-cadence)
- [Instance lifetime](#instance-lifetime)
- [Error idiom](#error-idiom)
- [Options trivia](#options-trivia)
- [Conventions baked into the descriptions](#conventions-baked-into-the-descriptions)
- [Things the protocol doesn't expose yet](#things-the-protocol-doesnt-expose-yet)
- [Connecting an MCP client](#connecting-an-mcp-client)
- [End-to-end example — curl (live)](#end-to-end-example--curl-live)

## Server

To start the MCP server:

```bash
bin/spectre_mcp_server
```

To see CLI options:

```bash
bin/spectre_mcp_server -h
```

The transport is [Streamable HTTP][http] — every call is a JSON-RPC `POST`,
optionally upgraded to a Server-Sent Events stream by the server.
Authentication is configured in-application (see _Auth_ below); there are
no `--username` / `--password` flags.

[http]: https://modelcontextprotocol.io/docs/concepts/transports#streamable-http

## Endpoint

A single URL — `http://<host>:<port>/mcp`. There is no per-instance
sub-route; instance scoping is done by passing `instance_id` as an
argument to every per-scan tool. One MCP server, one session per client.

`serverInfo` advertises `{ name: "spectre", version: "<release>" }`,
matching the running build. The brand and version are picked up
automatically — there's nothing to
configure on the CLI.

## Tools

The server flattens framework + scan tools into one `tools/list` response.
Every tool that returns structured data declares an `outputSchema`; the
response carries _both_ `content[0].text` (JSON-encoded, for clients that
don't speak typed outputs) _and_ `structuredContent` matching the schema
(for clients that do).

### Framework tools

| Tool             | Required        | Optional                              | Returns (`structuredContent`) |
|------------------|-----------------|---------------------------------------|-------------------------------|
| `list_instances` | —               | —                                     | `{ instances: { <id>: { url } } }` |
| `spawn_instance` | —               | `options`, `start=true`, `live=true`  | `{ instance_id, url, live? }` |
| `kill_instance`  | `instance_id`   | —                                     | `{ killed: <id> }`            |
| `list_checks`    | —               | `severities[]`, `tags[]`              | `{ checks: [{ shortname, name, description, severity, elements[], tags[], platforms[] }] }` |
| `list_plugins`   | —               | —                                     | `{ plugins: [{ shortname, name, description, default, options[] }] }` |

`list_checks` is the catalog tool — call it BEFORE `spawn_instance` to
discover what's available and pick the `shortname`s you want to scope
into `options.checks`. Filterable by `severities` (e.g. just `high`) or
`tags` (e.g. `xss`, `sqli`). The response is sorted high-severity-first
then by name.

`list_plugins` is the parallel catalog for plugins — shortname + name
+ description + per-plugin config schema. Plugins flagged
`default: true` auto-load on every scan; you can name additional ones
in `options.plugins` (array form: `["webhook_notify"]`) or pass config
inline (hash form: `{ "webhook_notify": { "url": "https://..." } }`)
using the keys in each plugin's `options[]` array. The `live` plugin
is intentionally hidden — it's auto-attached by the MCP server when
the session supports notifications, not a knob clients toggle.

`spawn_instance.options` is forwarded to `instance.run(...)`. To
spawn an _Instance_ without running anything, pass `start: false`;
passing `options: {}` does **not** skip the run.

`live` is on by default — when the call arrives over an MCP session
that supports notifications, the server attaches a per-instance
loopback receiver and the engine pushes every issue / sitemap entry /
error / status change / final report back to the calling session as
a brand-derived JSON-RPC notification. The response's `live`
sub-object tells the client which notification method to subscribe
to (e.g. `notifications/spectre/live`). See
[Live events](#live-events) for the envelope shape and the
end-to-end flow. Pass `live: false` to opt out and poll instead.

For the full options surface, read the
[`spectre://options/reference`](#resources) resource (covered below)
or the inlined [Options reference](#options-reference) further down
this page.

### Per-scan tools

Every per-scan tool requires `instance_id`. Two delta-arg shapes:

- `*_seen` — array of issue digests already processed; the response
  excludes those.
- `*_since` — integer offset; the response is the tail past that index.

| Tool            | Required        | Optional                                                                                  | Returns                              |
|-----------------|-----------------|-------------------------------------------------------------------------------------------|--------------------------------------|
| `scan_progress` | `instance_id`   | `issues_seen`, `errors_since`, `sitemap_since`, `without_issues`, `without_errors`, `without_sitemap`, `without_statistics` | `{ status, running, seed, statistics?, issues?, errors?, sitemap?, messages }` |
| `scan_report`   | `instance_id`   | —                                                                                         | `{ issues, sitemap, statistics, plugins }` |
| `scan_sitemap`  | `instance_id`   | `sitemap_since=0`                                                                         | `{ sitemap: { <url>: <code> } }`     |
| `scan_issues`   | `instance_id`   | `issues_seen=[]`                                                                          | `{ issues: { <digest>: <issue> } }`  |
| `scan_errors`   | `instance_id`   | `errors_since=0`                                                                          | `{ errors: [string] }`               |
| `scan_pause`    | `instance_id`   | —                                                                                         | `{ status: 'paused' }`               |
| `scan_resume`   | `instance_id`   | —                                                                                         | `{ status: 'resumed' }`              |
| `scan_abort`    | `instance_id`   | —                                                                                         | `{ status: 'aborted' }`              |

### Issue digests

Issue `digest` values are the **keys** of the returned `issues` hash
(NOT a field nested inside the value) — unsigned 32-bit `xxh32`
integers, e.g. `3162940604`. Both `scan_progress` and `scan_issues`
accept the digest array as integers or numeric strings (some JSON-RPC
clients stringify large numbers); the server coerces. If you ever see
the same issue stream back unchanged after passing it as `issues_seen`,
a stringified-vs-int mismatch is the first thing to check.

## Prompts

| Prompt               | Required | Description                                                                                  |
|----------------------|----------|----------------------------------------------------------------------------------------------|
| `quick_scan(url)`    | `url`    | Canned operator workflow for the **bounded smoke test** — expands into a 6-step user message that walks the AI through reading the options reference, building `options` from the quick-scan preset (`scope.page_limit: 50` baked in), `spawn_instance`, polling `scan_progress` every 5 s using deltas, fetching `scan_issues` when status reaches `done`, and `kill_instance`-ing afterwards. Optional args: `page_limit` (override the default cap), `checks`, `authorized_by`, `extra_options`. |
| `full_scan(url)`     | `url`    | Same shape as `quick_scan` minus the 50-page cap — drives a complete audit using the full-scan preset. Use when you want a thorough run and accept hours of polling. Optional args: `checks`, `authorized_by`, `extra_options`. |

The expanded prompt body references resources by URI so the model has a
clear pull path for the data — it doesn't need to memorise option names.

## Resources

| URI                                       | Mime               | Contents                                                                          |
|-------------------------------------------|--------------------|-----------------------------------------------------------------------------------|
| `spectre://glossary`                      | `text/markdown`    | Domain terms (issue, digest, status, sitemap, statistics, check, scope, audit.elements). Read once before driving a scan. |
| `spectre://options/reference`             | `text/markdown`    | Concrete keys for `spawn_instance.options` (url, scope, audit, checks, http, dom, plugins, authorized_by). |
| `spectre://option-presets/quick-scan`     | `application/json` | JSON template — every audit element, every check, default plugins, **`scope.page_limit: 50`** so a real-site smoke test finishes in minutes. Bump / drop the cap (or switch to `full-scan`) for a longer run. |
| `spectre://option-presets/full-scan`      | `application/json` | Same shape as `quick-scan` minus the page cap — uncapped audit. Use when you want a complete run and accept a long wait. |

Quick-scan preset:

```json
{
  "url":     "<TARGET URL>",
  "checks":  ["*"],
  "audit":   { "elements": ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"] },
  "scope":   { "page_limit": 50 }
}
```

Full-scan preset (same minus `scope`):

```json
{
  "url":    "<TARGET URL>",
  "checks": ["*"],
  "audit":  { "elements": ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"] }
}
```

Pulled in-band, this gives an AI client everything it needs to schematise
`spawn_instance.options` without leaving the protocol.

## Options reference

> Same content is served at
> [`spectre://options/reference`](#resources).


The full option surface accepted by `spawn_instance.options`.
Hash, all keys optional.

The bare engine defaults leave every audit element OFF and every
check unloaded; only `bin/spectre_scan` (and the option presets)
enable them. If you build options from scratch, ship at least
`url`, `audit.elements` (or per-element booleans), and `checks`,
or use `spectre://option-presets/quick-scan`.

### Wire shape

This is what gets sent as `spawn_instance.options` — a single
nested JSON object, all groups optional, every leaf documented
further down. Each
top-level key is its own JSON object (`audit`, `scope`, `http`,
`dom`, `device`, `input`, `session`, `timeout`); the
top-level scalars (`url`, `checks`, `plugins`, `authorized_by`,
`no_fingerprinting`) sit alongside.

```json
{
  "url":     "http://example.com/",
  "checks":  ["*"],
  "plugins": {},
  "authorized_by":     "you@example.com",
  "no_fingerprinting": false,

  "audit": {
    "elements":             ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"],
    "link_templates":       [],
    "parameter_values":     true,
    "parameter_names":      false,
    "with_raw_payloads":    false,
    "with_extra_parameter": false,
    "with_both_http_methods": false,
    "cookies_extensively":  false,
    "mode":                 "moderate",
    "exclude_vector_patterns": [],
    "include_vector_patterns": []
  },

  "scope": {
    "page_limit":                  50,
    "depth_limit":                 10,
    "directory_depth_limit":       10,
    "dom_depth_limit":             4,
    "dom_event_limit":             500,
    "dom_event_inheritance_limit": 500,
    "include_subdomains":          false,
    "https_only":                  false,
    "include_path_patterns":       [],
    "exclude_path_patterns":       [],
    "exclude_content_patterns":    [],
    "exclude_file_extensions":     ["gif","mp4","pdf","js","css"],
    "exclude_binaries":            false,
    "restrict_paths":              [],
    "extend_paths":                [],
    "redundant_path_patterns":     {},
    "auto_redundant_paths":        15,
    "url_rewrites":                {}
  },

  "http": {
    "request_concurrency":     10,
    "request_queue_size":      50,
    "request_timeout":         20000,
    "request_redirect_limit":  5,
    "response_max_size":       500000,
    "request_headers":         {},
    "cookies":                 {},
    "cookie_jar_filepath":     "/path/to/cookies.txt",
    "cookie_string":           "name=value; Path=/",
    "authentication_username": "user",
    "authentication_password": "pass",
    "authentication_type":     "auto",
    "proxy":                   "host:port",
    "proxy_host":              "host",
    "proxy_port":              8080,
    "proxy_username":          "user",
    "proxy_password":          "pass",
    "proxy_type":              "auto",
    "ssl_verify_peer":         false,
    "ssl_verify_host":         false,
    "ssl_certificate_filepath":"/path/to/cert.pem",
    "ssl_certificate_type":    "pem",
    "ssl_key_filepath":        "/path/to/key.pem",
    "ssl_key_type":            "pem",
    "ssl_key_password":        "secret",
    "ssl_ca_filepath":         "/path/to/ca.pem",
    "ssl_ca_directory":        "/path/to/ca-dir/",
    "ssl_version":             "tlsv1_3"
  },

  "dom": {
    "engine":              "chrome",
    "pool_size":           4,
    "job_timeout":         120,
    "worker_time_to_live": 1000,
    "wait_for_timers":     false,
    "local_storage":       {},
    "session_storage":     {},
    "wait_for_elements":   {}
  },

  "device": {
    "visible":     false,
    "width":       1600,
    "height":      1200,
    "user_agent":  "...",
    "pixel_ratio": 1.0,
    "touch":       false
  },

  "input": {
    "values":           {},
    "default_values":   {},
    "without_defaults": false,
    "force":            false
  },

  "session": {
    "check_url":     "https://example.com/account",
    "check_pattern": "Logout"
  },

  "timeout": {
    "duration": 3600,
    "suspend":  false
  }
}
```

In the per-key sections below, **`group.key` is shorthand for the
JSON path `{ "group": { "key": ... } }`** — `audit.elements`
means the `elements` field of the `audit` object, not a literal
key called `audit.elements`.

### Table of contents

- [Top-level](#top-level)
  - [`url`](#url)
  - [`checks`](#checks)
  - [`plugins`](#plugins)
  - [`authorized_by`](#authorized_by)
  - [`no_fingerprinting`](#no_fingerprinting)
- [`audit`](#audit) — what the engine traces
  - [`audit.elements`](#auditelements)
  - [Per-element toggles](#per-element-toggles)
  - [`audit.link_templates`](#auditlink_templates)
  - [`audit.parameter_values`](#auditparameter_values) / [`parameter_names`](#auditparameter_names)
  - [`audit.with_raw_payloads`](#auditwith_raw_payloads) / [`with_extra_parameter`](#auditwith_extra_parameter) / [`with_both_http_methods`](#auditwith_both_http_methods)
  - [`audit.cookies_extensively`](#auditcookies_extensively)
  - [`audit.mode`](#auditmode)
  - [`audit.exclude_vector_patterns`](#auditexclude_vector_patterns) / [`include_vector_patterns`](#auditinclude_vector_patterns)
- [`scope`](#scope) — crawl bounds
  - [`scope.page_limit`](#scopepage_limit)
  - [`scope.depth_limit`](#scopedepth_limit) / [`directory_depth_limit`](#scopedirectory_depth_limit)
  - [`scope.dom_depth_limit`](#scopedom_depth_limit) / [`dom_event_limit`](#scopedom_event_limit) / [`dom_event_inheritance_limit`](#scopedom_event_inheritance_limit)
  - [`scope.include_subdomains`](#scopeinclude_subdomains) / [`https_only`](#scopehttps_only)
  - [`scope.include_path_patterns`](#scopeinclude_path_patterns) / [`exclude_path_patterns`](#scopeexclude_path_patterns) / [`exclude_content_patterns`](#scopeexclude_content_patterns)
  - [`scope.exclude_file_extensions`](#scopeexclude_file_extensions) / [`exclude_binaries`](#scopeexclude_binaries)
  - [`scope.restrict_paths`](#scoperestrict_paths) / [`extend_paths`](#scopeextend_paths)
  - [`scope.redundant_path_patterns`](#scoperedundant_path_patterns) / [`auto_redundant_paths`](#scopeauto_redundant_paths)
  - [`scope.url_rewrites`](#scopeurl_rewrites)
- [`http`](#http) — HTTP client tuning
  - [Concurrency / queue / timeouts](#concurrency--queue--timeouts)
  - [Headers / cookies](#headers--cookies)
  - [HTTP authentication](#http-authentication)
  - [Proxy](#proxy)
  - [TLS / SSL](#tls--ssl)
- [`dom`](#dom) — browser cluster + DOM crawl
- [`device`](#device) — viewport / identity
- [`input`](#input) — auto-fill rules
- [`session`](#session) — login-session monitoring
- [`timeout`](#timeout) — wall-clock cap

---

### Top-level

#### `url`

*(string, required for a real scan)*

The target. Anything reachable over HTTP(S). Required for any
`spawn_instance` with `start: true`; the only spawn path where
it can be omitted is `start: false` (an idle instance set up to
be configured later).

```json
{ "url": "http://example.com/" }
```

#### `checks`

*(string[], default: `[]` — no checks loaded)*

Check shortnames or globs to load. Use `["*"]` for the full
catalogue (the `bin/spectre_scan` default). Examples:

- `["xss*", "sql_injection*"]` — XSS family + SQLi family.
- `["xss"]` — exactly the `xss` check.

Call the `list_checks` MCP tool (or `bin/spectre_scan
--list-checks`) to enumerate the available shortnames + their
severity / tags / element coverage.

```json
{ "checks": ["xss*", "sql_injection*"] }
```

#### `plugins`

*(object | string[] | string, default: `{}` — no plugins)*

Plugins to load. Three accepted shapes:

```json
{ "plugins": {} }                                    // load nothing extra
{ "plugins": ["defaults/*"] }                        // array of names / globs
{ "plugins": { "webhook_notify": { "url": "..." } } } // hash with per-plugin options
```

The application **always** merges its default-plugin set in
first; this key is purely for extras / overrides.

#### `authorized_by`

*(string)*

E-mail address of the authorising operator. Flows into outbound
HTTP requests' `From` header so target-site admins can identify
the scan. Polite on third-party targets.

```json
{ "authorized_by": "ops@example.com" }
```

#### `no_fingerprinting`

*(boolean, default: false)*

Skip server / client tech fingerprinting. The fingerprint feeds
`platforms` on each issue (`tomcat,java`, `php,mysql`, etc.) and
narrows which checks run; turning it off speeds the start-up but
loses platform-specific check skipping.

```json
{ "no_fingerprinting": true }
```

---

### `audit`

What the engine traces. All keys nest under the top-level
`"audit"` object:

```json
{ "audit": { "elements": ["links","forms"], "parameter_values": true } }
```

#### `audit.elements`

*(string[])*

Shortcut for the per-element booleans below. Pick from:
`links`, `forms`, `cookies`, `nested_cookies`, `headers`,
`ui_inputs`, `ui_forms`, `jsons`, `xmls`. Equivalent to setting
each named boolean to `true`.

The presets ship the standard 8-element list (`links`, `forms`,
`cookies`, `headers`, `ui_inputs`, `ui_forms`, `jsons`, `xmls`).
`nested_cookies` is opt-in; `link_templates` is **not** an
element — see below.

```json
{ "audit": { "elements": ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"] } }
```

#### Per-element toggles

`audit.links` / `audit.forms` / `audit.cookies` /
`audit.headers` / `audit.jsons` / `audit.xmls` /
`audit.ui_inputs` / `audit.ui_forms` / `audit.nested_cookies`

*(boolean)*

Equivalent to listing the element name in `audit.elements`.
Default on each is unset (`nil`), which the engine treats as
off; `bin/spectre_scan` flips them on for the default 8.

```json
{ "audit": { "links": true, "forms": true, "cookies": false } }
```

#### `audit.link_templates`

*(regex[], default: `[]`)*

Regex patterns with named captures for extracting input info
from REST-style paths. Example: `(?<id>\d+)` against
`/users/42` lets the engine treat `42` as the value of an
`id` input. **Not** a boolean toggle — putting `link_templates`
in `audit.elements` is an error.

```json
{ "audit": { "link_templates": ["users/(?<id>\\d+)", "posts/(?<post_id>\\d+)"] } }
```

#### `audit.parameter_values`

*(boolean, default: true)*

Inject payloads into parameter values. Turning this off limits
auditing to parameter *names* (with `parameter_names: true`) or
extra-parameter injection — rarely what you want.

#### `audit.parameter_names`

*(boolean, default: false)*

Inject payloads into parameter names themselves. Catches
mass-assignment / unintended-parameter classes of bug. Adds one
extra mutation per known input.

#### `audit.with_raw_payloads`

*(boolean, default: false)*

Send payloads in raw form (no HTTP encoding). Useful when you
suspect the target has a decoder that mangles encoded bytes.

#### `audit.with_extra_parameter`

*(boolean, default: false)*

Inject an additional, unexpected parameter into each element.
Catches code paths that read undeclared parameters.

#### `audit.with_both_http_methods`

*(boolean, default: false)*

Audit each link / form with both `GET` and `POST`. **Doubles
audit time** — only enable when the target's behaviour is
known to vary by method.

#### `audit.cookies_extensively`

*(boolean, default: false)*

Submit every link and form along with each cookie permutation.
**Severely increases scan time** — useful when cookie state
gates application behaviour.

#### `audit.mode`

*(string, default: `"moderate"`)*

Audit aggressiveness. Values: `light`, `moderate`, `aggressive`.
Higher modes try more payload variants per input.

#### `audit.exclude_vector_patterns`

*(regex[], default: `[]`)*

Skip input vectors whose name matches any pattern. Example:
`["^csrf$", "^_token$"]` to leave anti-CSRF tokens alone.

#### `audit.include_vector_patterns`

*(regex[], default: `[]`)*

Inverse of `exclude_vector_patterns` — only audit vectors whose
name matches. Empty means "no whitelist."

---

### `scope`

Crawl bounds. All keys nest under `"scope"`:

```json
{ "scope": { "page_limit": 50, "include_subdomains": false } }
```

#### `scope.page_limit`

*(int, default: nil — infinite)*

Hard cap on crawled pages. The quick-scan preset sets this to
`50`; the full-scan preset omits it.

#### `scope.depth_limit`

*(int, default: 10)*

How deep to follow links from the seed. Counts every hop
regardless of directory layout.

#### `scope.directory_depth_limit`

*(int, default: 10)*

How deep to descend into the URL path tree.

#### `scope.dom_depth_limit`

*(int, default: 4)*

How deep into the DOM tree of each JavaScript-rendered page.
`0` disables browser analysis entirely.

#### `scope.dom_event_limit`

*(int, default: 500)*

Max DOM events triggered per DOM depth. Caps crawl time on
event-heavy SPAs.

#### `scope.dom_event_inheritance_limit`

*(int, default: 500)*

How many descendant elements inherit a parent's bound events.

#### `scope.include_subdomains`

*(boolean, default: false)*

Follow links to subdomains of the seed host.

#### `scope.https_only`

*(boolean, default: false)*

Refuse plaintext HTTP follow-throughs.

#### `scope.include_path_patterns`

*(regex[], default: `[]`)*

Whitelist patterns for path segments. Empty = include all.

#### `scope.exclude_path_patterns`

*(regex[], default: `[]`)*

Blacklist patterns. Pages whose paths match are skipped.

```json
{ "scope": { "exclude_path_patterns": ["/logout", "/admin/.*"] } }
```

#### `scope.exclude_content_patterns`

*(regex[], default: `[]`)*

Blacklist patterns for *response body* content. A page whose
body matches gets dropped from the audit pool — useful for
"don't audit /logout" via response-side pattern.

#### `scope.exclude_file_extensions`

*(string[])*

Skip URLs ending in these extensions. Defaults to a long list
of media / archive / executable / asset / document extensions
(`gif`, `mp4`, `pdf`, `js`, `css`, …). Override if you need to
audit something the default skips (e.g. force-include `js` for
DOM analysis).

#### `scope.exclude_binaries`

*(boolean, default: false)*

Skip non-text-typed responses. Cheaper than maintaining a
content-type allowlist; can confuse passive checks that
pattern-match on bodies.

#### `scope.restrict_paths`

*(string[], default: `[]`)*

Use these paths INSTEAD of crawling. Pre-seeded path discovery
— the engine audits exactly what's listed.

#### `scope.extend_paths`

*(string[], default: `[]`)*

Add to whatever the crawler discovers. Useful for hidden URLs
that aren't linked from anywhere.

#### `scope.redundant_path_patterns`

*(object: `{regex: int}`, default: `{}`)*

Pages matching the regex are crawled at most `N` times. Stops
infinite-calendar / infinite-page traps.

```json
{ "scope": { "redundant_path_patterns": { "calendar/\\d+": 1, "events/\\d+": 5 } } }
```

#### `scope.auto_redundant_paths`

*(int, default: 15)*

Follow URLs with the same query-parameter-name combination at
most `auto_redundant_paths` times. Catches the
`?page=1&offset=10`, `?page=2&offset=20`, ... pattern without
needing explicit `redundant_path_patterns`.

#### `scope.url_rewrites`

*(object: `{regex: string}`, default: `{}`)*

Rewrite seed-discovered URLs before audit:

```json
{ "scope": { "url_rewrites": { "articles/(\\d+)": "articles.php?id=\\1" } } }
```

---

### `http`

HTTP client tuning. All keys nest under `"http"`:

```json
{ "http": { "request_concurrency": 5, "request_timeout": 30000 } }
```

#### Concurrency / queue / timeouts

- **`http.request_concurrency`** *(int, default: 10)* — parallel
  requests in flight. The engine throttles down automatically if
  the target's response time degrades.
- **`http.request_queue_size`** *(int, default: 50)* — max
  requests queued client-side. Larger queue = better network
  utilisation, more RAM.
- **`http.request_timeout`** *(int, ms, default: 20000)* —
  per-request timeout.
- **`http.request_redirect_limit`** *(int, default: 5)* — max
  redirects to follow on each request.
- **`http.response_max_size`** *(int, bytes, default: 500000)* —
  don't download response bodies larger than this. Prevents
  runaway RAM on a target that streams large payloads.

#### Headers / cookies

- **`http.request_headers`** *(object, default: `{}`)* — extra
  headers on every request:

  ```json
  { "http": { "request_headers": { "X-API-Key": "abc123", "X-Debug": "1" } } }
  ```

- **`http.cookies`** *(object, default: `{}`)* — preset cookies:

  ```json
  { "http": { "cookies": { "session_id": "abc", "auth": "xyz" } } }
  ```

- **`http.cookie_jar_filepath`** *(string)* — path to a
  Netscape-format cookie jar file.
- **`http.cookie_string`** *(string)* — raw cookie string,
  `Set-Cookie`-style:

  ```json
  { "http": { "cookie_string": "my_cookie=my_value; Path=/, other=other; Path=/test" } }
  ```

#### HTTP authentication

```json
{ "http": {
    "authentication_username": "user",
    "authentication_password": "pass",
    "authentication_type":     "basic"
} }
```

- **`http.authentication_username`** / **`http.authentication_password`** *(string)*
- **`http.authentication_type`** *(string, default: `"auto"`)* —
  explicit values: `basic`, `digest`, `ntlm`, `negotiate`, `any`,
  `anysafe`.

#### Proxy

```json
{ "http": {
    "proxy":          "proxy.example.com:8080",
    "proxy_type":     "http",
    "proxy_username": "user",
    "proxy_password": "pass"
} }
```

- **`http.proxy`** *(string, `"host:port"` shortcut)*
- **`http.proxy_host`** / **`http.proxy_port`** — split form,
  overrides `proxy` if set.
- **`http.proxy_username`** / **`http.proxy_password`** *(string)*
- **`http.proxy_type`** *(string, default: `"auto"`)* — `http`,
  `https`, `socks4`, `socks4a`, `socks5`, `socks5_hostname`.

#### TLS / SSL

- **`http.ssl_verify_peer`** / **`http.ssl_verify_host`**
  *(boolean, default: false)* — TLS peer / hostname verification.
  Off by default; both `true` for full chain validation.
- **`http.ssl_certificate_filepath`** / **`http.ssl_certificate_type`**
  / **`http.ssl_key_filepath`** / **`http.ssl_key_type`** /
  **`http.ssl_key_password`** — client-cert auth. `*_type`
  values: `pem`, `der`, `eng`.
- **`http.ssl_ca_filepath`** / **`http.ssl_ca_directory`** —
  custom CA bundle / directory for peer verification.
- **`http.ssl_version`** *(string)* — pin a TLS version: `tlsv1`,
  `tlsv1_0`, `tlsv1_1`, `tlsv1_2`, `tlsv1_3`, `sslv2`, `sslv3`.

```json
{ "http": {
    "ssl_verify_peer":          true,
    "ssl_verify_host":          true,
    "ssl_ca_filepath":          "/etc/ssl/cert.pem",
    "ssl_certificate_filepath": "/path/to/client.pem",
    "ssl_key_filepath":         "/path/to/client.key",
    "ssl_version":              "tlsv1_3"
} }
```

---

### `dom`

Browser cluster + DOM crawl. All keys nest under `"dom"`:

```json
{ "dom": { "pool_size": 4, "job_timeout": 120, "wait_for_timers": true } }
```

- **`dom.engine`** *(string, default: `"chrome"`)* — browser
  engine. Chrome is the only supported value.
- **`dom.pool_size`** *(int, default: `min(cpu_count/2, 10) || 1`)* —
  number of browser workers in the pool. More workers = faster
  DOM crawl on JS-heavy targets, more RAM.
- **`dom.job_timeout`** *(int, sec, default: 120)* — per-page
  browser job ceiling. Pages that don't settle are dropped from
  DOM-side analysis.
- **`dom.worker_time_to_live`** *(int, default: 1000)* — re-spawn
  each browser after this many jobs. Caps memory leaks in
  long-lived headless instances.
- **`dom.wait_for_timers`** *(boolean, default: false)* — wait
  for the longest `setTimeout()` on each page before considering
  DOM analysis "done". Catches lazy-mounted UI.
- **`dom.local_storage`** / **`dom.session_storage`** *(object,
  default: `{}`)* — pre-seed key/value maps:

  ```json
  { "dom": {
      "local_storage":   { "user": "abc", "preferred_lang": "en" },
      "session_storage": { "csrf_token": "xyz" }
  } }
  ```

- **`dom.wait_for_elements`** *(object: `{regex: css}`, default:
  `{}`)* — when navigating to a URL matching the key, wait for
  the CSS selector value to match before continuing:

  ```json
  { "dom": { "wait_for_elements": {
      "/dashboard":  "#main-app .ready",
      "/settings/.*": "#settings-form"
  } } }
  ```

---

### `device`

Browser viewport / identity. All keys nest under `"device"`:

```json
{ "device": { "width": 375, "height": 812, "touch": true, "pixel_ratio": 3.0 } }
```

- **`device.visible`** *(boolean, default: false)* — show the
  browser window (head-ful mode). Massively slower; primarily
  for debugging login flows / interactive traps.
- **`device.width`** / **`device.height`** *(int)* — viewport
  dimensions in CSS pixels.
- **`device.user_agent`** *(string)* — override the User-Agent
  header / JS API.
- **`device.pixel_ratio`** *(float, default: 1.0)* — device
  pixel ratio. Bump for high-DPI sniffing (some sites serve
  different markup at `2.0`).
- **`device.touch`** *(boolean, default: false)* — advertise as
  a touch device.

---

### `input`

How inputs are auto-filled by the engine before mutation. All
keys nest under `"input"`:

```json
{ "input": { "values": { "email": "scan@example.com" }, "force": true } }
```

- **`input.values`** *(object: `{regex: string}`, default: `{}`)*
  — match an input's name against the regex key; use the value:

  ```json
  { "input": { "values": {
      "email":          "scan@example.com",
      "first_name":     "Scan",
      "creditcard|cc":  "4111111111111111"
  } } }
  ```

- **`input.default_values`** *(object)* — layered under `values`
  — patterns the engine ships out of the box (`first_name` →
  "John", etc.).
- **`input.without_defaults`** *(boolean, default: false)* —
  skip the shipped `default_values` table; only your `values`
  get used.
- **`input.force`** *(boolean, default: false)* — fill even
  non-empty inputs (overwrites pre-populated form fields).

---

### `session`

Login-session monitoring. The engine periodically checks the
target is still logged in. All keys nest under `"session"`:

```json
{ "session": {
    "check_url":     "https://example.com/account",
    "check_pattern": "Logout"
} }
```

- **`session.check_url`** *(string)* — URL whose response body
  should match `check_pattern` while the session is valid.
- **`session.check_pattern`** *(regex)* — matched against
  `check_url`'s body. Mismatch = session expired; the scan halts
  pending re-login.

Both fields are required to enable session monitoring; setting
only one is rejected at validation time.

---

### `timeout`

Wall-clock cap on the run. All keys nest under `"timeout"`:

```json
{ "timeout": { "duration": 3600, "suspend": true } }
```

- **`timeout.duration`** *(int, sec)* — stop the scan after this
  many seconds.
- **`timeout.suspend`** *(boolean, default: false)* — when the
  timeout fires, suspend to a snapshot file (loadable later out of
  band). Without this the run is aborted.

---


## Auth

Authentication is opt-in. When an embedder registers a bearer-
token validator at boot, the server requires
`Authorization: Bearer <token>` on every request and returns `401`
otherwise (RFC 6750 — `WWW-Authenticate: Bearer realm="MCP", error=…`).
Without a validator the server accepts unauthenticated traffic — fine for
a loopback bind, dangerous on a public interface.

The resolved principal is stashed at `env['cuboid.mcp.auth']` for any
downstream middleware that wants to look it up.

## Self-discovery flow

If you're an AI seeing this server for the first time, do this once:

1. `initialize` → check `serverInfo.name` (`spectre`) and `version`.
2. `resources/list` → you'll see four URIs. **Read all four** — they
   are tiny and answer most of the questions you'd otherwise have to
   ask. The glossary in particular grounds the field names you'll see
   in `scan_progress` / `scan_issues` results.
3. `prompts/list` → you'll see `quick_scan` (capped 50-page smoke test)
   and `full_scan` (uncapped). If the user's intent
   matches it ("scan this URL for issues"), use it: `prompts/get` with
   their URL gives you a full operator script.
4. `tools/list` → discover the 12 tools. `outputSchema` on each tells
   you exactly what `structuredContent` to expect. `list_checks` (no
   `instance_id` required) hands back the full check catalog so you
   can scope `spawn_instance.options.checks` deliberately instead of
   defaulting to `["*"]`.
5. Open the GET-SSE channel on `/mcp` (with the same `mcp-session-id`)
   to receive [live events](#live-events). The default `spawn_instance`
   call will start streaming on it — you do not need to poll unless
   you opt out of live with `live: false`.

After that, drive the scan with no further out-of-band knowledge.

## Status semantics

`scan_progress.status` advances roughly:

```
ready ──► preparing ──► scanning ──► auditing ──► cleanup ──► done
                              │           │
                              └─► paused ─┘
                              │
                              └─► aborted (terminal)
```

- `ready` — the _Instance_ has been spawned but `start: true` hasn't yet
  flipped it past `instance.run(...)`. **`scan_progress` called on a
  `:ready` instance returns a minimal payload** (status + running +
  seed only — no statistics yet, no issues hash). Don't trust delta
  arithmetic until status has advanced.
- `preparing` — engine is loading checks/plugins, opening the seed URL,
  and warming the browser cluster. No issues yet, but the sitemap may
  start populating.
- `scanning` — crawl is in flight; new sitemap entries appear, no
  audits running yet.
- `auditing` — the crawl is winding down and checks are firing against
  discovered inputs. Most issues land here.
- `paused` / `aborted` — `running: false`, but only `aborted` is
  terminal. A paused scan can be resumed with `scan_resume`.
- `cleanup` — engine is finalising state; close to `done`.
- `done` — terminal. `scan_report` is now safe to call;
  `running: false`.

**Treat anything other than `done` / `aborted` as still in flight.**

## Live events

The canonical way to track a scan is the live channel — `spawn_instance`
attaches it by default. Every interesting state change inside the
engine is pushed to the calling MCP session as a brand-derived
JSON-RPC notification (`notifications/spectre/live` for Spectre);
your client subscribes once on the SSE half of the Streamable HTTP
transport and receives them as they happen, with no polling.

### Subscribing

Streamable HTTP is one URL with two halves: `POST /mcp` for
request/response and `GET /mcp` (with `Accept: text/event-stream`)
for server-initiated notifications. Open the GET once after
`initialize`, before any `spawn_instance`, and keep it open for the
life of the scan. Use the **same** `mcp-session-id` you got from
`initialize` on both halves — that's how the server routes the
notifications back to the right client.

The exact notification method to listen for is
brand-derived; `spawn_instance`'s response includes
`live.notification_method` so the client doesn't have to hard-code
it. Bare-cuboid builds emit `notifications/cuboid/live`.

### Envelope shape

Each notification's `params` is a single envelope:

```jsonc
{
  "jsonrpc": "2.0",
  "method":  "notifications/spectre/live",
  "params": {
    "type":        "issue",            // see type enum below
    "payload":     { … },              // type-specific body, see below
    "timestamp":   "2026-05-05T10:48:01.715Z",
    "status":      "auditing",         // current scan status at emit time
    "running":     true,
    "statistics":  { … },              // engine statistics snapshot at emit time
    "metadata":    { … },              // caller-supplied JSON object, if any (see below)
    "instance_id": "f8cd1a0a…"         // stamped on every event so a single
                                       // session can fan in multiple scans
  }
}
```

`type` is one of:

| `type`           | `payload` shape                                              | when |
|------------------|--------------------------------------------------------------|------|
| `status`         | string — see status payload sequence below                   | every status transition + the synthetic `started` / `exited` bookends |
| `sitemap_entry`  | `{ url: string, code: integer }`                             | every newly-crawled URL |
| `issue`          | full issue Hash (`name`, `severity`, `vector`, `proof`, `digest`, …) | every new finding (post-deduplication) |
| `error`          | string — one or more engine error lines, joined with newlines | rescued exceptions, coalesced over a 200 ms quiet window so a single backtrace becomes one event instead of 30+ |
| `report`         | full final report Hash (issues + sitemap + statistics + plugins) | once during `cleanup`, before the engine subprocess exits |

#### Status payload sequence

A typical run emits the following `status` payloads, in order:

```
started      ← synthetic — fired the moment the live plugin attaches,
                before the engine starts crawling. Useful as an "alive"
                signal: if the client never sees this, the spawn never
                got past plugin load.
preparing    ← engine loading checks/plugins, opening the seed URL
scanning     ← crawl in flight
auditing     ← payload exchange against discovered inputs
cleanup      ← engine finalising state; this is when `report` fires
done         ← terminal lifecycle status (or `aborted`)
exited       ← synthetic — fired from the live plugin's at_exit hook
                when the engine subprocess actually exits.
```

**`exited` is not automatic at `done`.** The engine subprocess stays
alive after `done` so subsequent `scan_report` calls keep working. It
only exits when the client calls `kill_instance` (or the host
terminates the process). Even then, the hook only fires on a graceful
unwind — a hard kill (SIGKILL, host crash, OOM) bypasses Ruby's
at_exit chain entirely, and no `exited` will ever land. Treat `done`
as "scan finished, results are stable" and `exited` as a best-effort
"engine subprocess is gone too." Don't block client teardown on
`exited` arriving.

`paused` and `resumed` can appear between `scanning`/`auditing` and
`cleanup` if the operator hits `scan_pause` / `scan_resume`.

`statistics` is the live counter snapshot at the moment the event
fired — issue totals by severity, page-queue depth, browser-pool
status, etc. Receivers can keep a running dashboard without ever
calling `scan_progress`.

### Tagging events with caller metadata

`spawn_instance` may include `plugins.live.metadata` (a JSON string).
At scan-start the plugin parses it once; every envelope thereafter
carries the decoded value verbatim under `metadata`. Use this to
correlate when one receiver fans in events from many concurrent
scans — e.g. `metadata = "{\"scan_id\":\"abc\",\"env\":\"staging\"}"`.
Invalid JSON in `metadata` aborts the scan at validation time
(`Component::Options::Error::Invalid`) — typos fail fast.

### Wire format

The live envelope is encoded in `messagepack` by default —
significantly smaller than JSON for the report payload (which
carries the full sitemap and issue set). The MCP server decodes it
internally and re-emits it as a normal JSON-RPC notification, so
clients see plain JSON. The format is opaque to clients.

### When to opt out

Pass `live: false` to `spawn_instance` if:

- You're driving from a stateless / non-MCP integration (no SSE
  channel to push to).
- You want a simpler client implementation that just polls.
- You're running under Apex — `live` is rejected at the application
  layer (Apex's sink-trace recon would flood the channel).

In any of those cases the [polling cadence](#polling-cadence)
section below is still valid.

## Polling cadence

Polling via `scan_progress` is the fallback when `live: false` (or
under Apex). 5 seconds is the default cadence the `quick_scan`
prompt suggests, and it's a sensible floor:

- Faster than ~2 s burns context tokens for almost no new state.
- `scan_progress` with `without_statistics: true` is cheap; the
  `statistics` block dwarfs the rest of the payload.
- Use `errors_since` / `sitemap_since` / `issues_seen` from the second
  poll onwards — the engine returns only deltas, keeping each response
  small.
- For very long scans (hours), 30 s is fine.

### Delta-arg shapes — when to use which

| Field          | Shape                          | Why                                                       |
|----------------|--------------------------------|-----------------------------------------------------------|
| `issues_seen`  | array of digests (int / string) | Issues are content-addressed; offsets aren't stable across deduplication. |
| `errors_since` | integer offset                 | Engine errors are an append-only log.                     |
| `sitemap_since`| integer offset                 | Sitemap is discovery-ordered, append-only.                |

`scan_progress` accepts all three at once — gives you exactly the right
delta for each block.

## Instance lifetime

Every `spawn_instance` forks a daemonised Spectre Scan engine subprocess on the
host (or, if a Cuboid Agent is configured, allocates one over the grid).
The `instance_id` is the engine's RPC token. Things to know:

- The instance survives a client disconnect. If you forget to call
  `kill_instance`, the process keeps running until something kills it
  (host shutdown, OOM, manual signal). Always wire a `kill_instance` in
  your error path.
- The instance does **not** survive an MCP-server restart cleanly. The
  daemonised engine keeps running but the MCP server's in-memory
  `@@instances` map is empty after a restart, so you can't
  `kill_instance` it through MCP any more (you'd need a process-level
  kill). **Don't restart the MCP server while scans are mid-flight.**
- Each instance reserves about 2 GB RAM and 4 GB disk by default. On a
  laptop, parallel scans are bounded by RAM; the host won't proactively
  refuse a third spawn if the second one is still warming up.
- `start: false` is rare in practice. It registers an idle instance
  that sits there waiting for a `run`, and MCP's `spawn_instance`
  doesn't have a separate "start now" tool — driving the run requires
  out-of-band RPC. Use it when something else is going to drive the run.

## Error idiom

Engine exceptions don't crash the MCP server — `MCPProxy.instrumented_call`
wraps every body with `rescue => e`. The wire response is:

```jsonc
{
  "result": {
    "isError": true,
    "content": [
      { "type": "text", "text": "error: <ErrorClass>: <message>" }
    ]
  }
}
```

Common shapes:

- `error: ArgumentError: Invalid options!` — `instance.run(options)`
  rejected the shape. Read `spectre://options/reference` and try again.
- `error: Toq::Exceptions::RemoteException: …` — the inner RPC client to
  the engine subprocess raised. Usually means the engine itself is in a
  bad state. Try `scan_errors` for clues; if that's empty,
  `kill_instance` and respawn.
- `error: JSON::GeneratorError: "\xNN" from ASCII-8BIT to UTF-8` — the
  engine produced binary bytes that aren't valid UTF-8 (a response body,
  HTTP header, etc.). Affects `scan_report` more than the streaming
  tools. Skip the report; `scan_progress` + `scan_issues` will still
  work.
- `unknown instance: …` — the `instance_id` you passed isn't in the
  server's local map. Either the MCP server was restarted (which clears
  `@@instances`), or the id is stale. Re-`spawn_instance`.

Validation errors (missing required arg, type mismatch) come back
through the JSON-RPC error envelope, not as a tool error:

```json
{ "error": { "code": -32602, "message": "Missing required arguments: instance_id" } }
```

## Options trivia

- `checks: "*"` (a single string) is **not** equivalent to
  `checks: ["*"]` (an array containing the wildcard). The string form
  won't expand. The preset and the option reference both use the array
  form.
- `plugins: ["defaults/*"]` loads every plugin under the `defaults`
  directory. Empty array (or omitted key) loads none.
- `audit.elements` defaults to all kinds when the key is omitted, which
  is what the CLI does. Pass an explicit list to restrict — e.g.
  `["links", "forms"]` skips cookies, headers, JSON/XML bodies, etc.
- `scope.page_limit` is baked into the quick-scan preset at **50** — a
  real-site smoke test that finishes in minutes. Override the
  `page_limit` prompt arg (or the JSON directly) for a smaller / larger
  cap; switch to the `full-scan` preset (or the `full_scan` prompt) for
  an uncapped audit. Sensible explicit values: 30 (smaller smoke test),
  200 (representative).
- `authorized_by` — set this to the operator's email; it shows up in
  the engine's outbound HTTP `From` header so target-site admins can
  identify the scan. Not required, but polite on third-party targets.

## Conventions baked into the descriptions

The tool / prompt / resource descriptions are deliberately self-grounding:

- Per-property descriptions on every tool argument (no buried-in-text
  args).
- Cross-references use namespaced names (`scan_resume`, not `resume`)
  so the AI can call them verbatim.
- Preconditions are stated where they exist (`scan_pause` "the scan
  must currently be running", `scan_resume` "must have been paused via
  `scan_pause`"). Calling out of order returns an MCP tool error rather
  than a routing failure.
- Domain terms (sink, mutation, action, vector, digest) are defined in
  `spectre://glossary` and cross-referenced from the relevant
  `outputSchema` property descriptions, so a model parsing
  `structuredContent` can resolve any unknown field name back to the
  glossary in one hop.

## Things the protocol doesn't expose yet

For honesty — places where you'd still need out-of-band knowledge:

- **Structured error codes.** Errors come back as text. If you want to
  branch on "bad option key" vs "engine crashed" vs "auth failed",
  you're parsing the text.

Each of those is on the roadmap. Until they land, the resources +
prompt expansion are the supported way to ground a model.

## Connecting an MCP client

Most clients accept a Streamable HTTP server entry verbatim:

```jsonc
{
  "mcpServers": {
    "spectre": {
      "url": "http://127.0.0.1:7331/mcp"
    }
  }
}
```

That's all. After `initialize`, the client sees:

- 12 tools (4 framework + 8 per-scan), each with input + output schema.
- 2 prompts (`quick_scan`, `full_scan`).
- 4 resources.

If your client only speaks stdio (older Claude Desktop builds), use any
community stdio↔HTTP MCP bridge in front. Cursor, Claude Code, and
Continue speak Streamable HTTP natively.

## End-to-end example — curl (live)

Initialize, capture the session id, acknowledge:

```bash
curl -i -X POST http://127.0.0.1:7331/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{
    "jsonrpc": "2.0", "id": 1, "method": "initialize",
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities":    {},
      "clientInfo":      { "name": "curl", "version": "0" }
    }
  }'
# → response header: Mcp-Session-Id: <SID>

curl -X POST http://127.0.0.1:7331/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Mcp-Session-Id: $SID" \
  --data '{ "jsonrpc": "2.0", "method": "notifications/initialized" }'
```

Open the SSE channel for live events — keep this connection open
for the life of the scan. Run it in another terminal (or
backgrounded) so the next POSTs can fire while it's tailing:

```bash
curl -sS -N -X GET http://127.0.0.1:7331/mcp \
  -H 'Accept: text/event-stream' \
  -H "Mcp-Session-Id: $SID"
# stream of `data: { "jsonrpc": "2.0", "method": "notifications/spectre/live", … }`
```

Spawn a scan against `http://testfire.net/` using the quick-scan
defaults — `live: true` is the default so the engine starts
streaming events to the SSE channel above immediately:

```bash
curl -X POST http://127.0.0.1:7331/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Mcp-Session-Id: $SID" \
  --data '{
    "jsonrpc": "2.0", "id": 2, "method": "tools/call",
    "params": {
      "name": "spawn_instance",
      "arguments": {
        "options": {
          "url":     "http://testfire.net/",
          "checks":  ["*"]
        }
      }
    }
  }'
# → result.structuredContent:
#   { "instance_id": "<IID>",
#     "url":         "127.0.0.1:<engine-port>",
#     "live":        { "notification_method": "notifications/spectre/live" } }
```

The SSE stream now emits one envelope per event — `status`
transitions, every newly-crawled `sitemap_entry`, every `issue`,
and a final `report` when status reaches `done`.

Tear down once the `report` event has landed:

```bash
curl -X POST http://127.0.0.1:7331/mcp ... \
  --data '{ "jsonrpc": "2.0", "id": 5, "method": "tools/call",
            "params": { "name": "kill_instance",
                        "arguments": { "instance_id": "'$IID'" } } }'
```

### Polling fallback

If you'd rather poll, pass `"live": false` on `spawn_instance` and
loop with `scan_progress` / `scan_issues`:

```bash
# spawn with live disabled
curl -X POST http://127.0.0.1:7331/mcp ... \
  --data '{ "jsonrpc": "2.0", "id": 2, "method": "tools/call",
            "params": { "name": "spawn_instance",
                        "arguments": {
                          "options": { "url": "http://testfire.net/", "checks": ["*"] },
                          "live":    false
                        } } }'

# poll, fetching deltas only after the first call
curl -X POST http://127.0.0.1:7331/mcp ... \
  --data '{ "jsonrpc": "2.0", "id": 3, "method": "tools/call",
            "params": { "name": "scan_progress",
                        "arguments": {
                          "instance_id":        "'$IID'",
                          "issues_seen":        [3162940604, 1457298731],
                          "errors_since":       12,
                          "sitemap_since":      37,
                          "without_statistics": true
                        } } }'
```

The same loops expressed as a `quick_scan` prompt expansion are one
`prompts/get` call away.
