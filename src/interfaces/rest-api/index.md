# REST API

Spectre Scan ships an HTTP/JSON REST surface for spawning, driving,
and tearing down engine instances; pairing them with a Scheduler;
and managing an Agent grid. It's a thin layer on top of the same
RPC plumbing the CLI and ui-pro use, so anything you can do
locally you can do over the network.

## Table of contents

- [Server](#server)
- [Conventions](#conventions)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
  - [Instances](#instances)
  - [Per-scan service (`/instances/:id/scan/...`)](#per-scan-service-instancesidscan)
  - [Scheduler](#scheduler)
  - [Agent](#agent)
  - [Grid](#grid)
- [Options reference](#options-reference)
- [Quick start](#quick-start)
- [Client (Ruby)](#client-ruby)
- [Incremental rescans via sessions](#incremental-rescans-via-sessions)
- [Status semantics](#status-semantics)
- [Things to know](#things-to-know)

## Server

```bash
bin/spectre_rest_server          # starts the server (defaults to 127.0.0.1:7331)
bin/spectre_rest_server -h       # CLI options
```

Useful flags:

- `--address HOST` / `--port N` -- bind interface and port.
- `--username USER` / `--password PASS` -- enable HTTP Basic auth.
- `--ssl-ca` / `--server-ssl-private-key` / `--server-ssl-certificate` --
  TLS termination + (with `--ssl-ca`) peer-cert verification.
- `--agent-url HOST:PORT` -- have the REST server hand instance
  spawning to an `Agent` (or grid) instead of forking locally.
- `--scheduler-url HOST:PORT` -- attach a Scheduler so `POST
  /scheduler` works.

## Conventions

- **Content-Type**: `application/json` everywhere, except
  `GET /instances/:id/report.crf` (binary `application/octet-stream`).
- **Session-bound**: the server uses `Rack::Session::Pool` and
  remembers per-cookie state -- `GET
  /instances/:id/scan/progress` returns *deltas* relative to what
  the calling cookie has already seen (issues / sitemap / errors).
  Hold the cookie across calls if you want cumulative output.
- **Errors**: `{ "error": <Class>, "description": <message>,
  "backtrace": [<frame>, ...] }` with status `5xx`. `404` for
  unknown instance / scheduler / agent. `503` from `POST
  /instances` when the host is at max utilisation.

## Authentication

Off by default. Pass `--username` and `--password` to enable HTTP
Basic. With both set, every request must carry an
`Authorization: Basic …` header or the server returns:

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Restricted Area"
```

For TLS, see the SSL flags above. CA-signed peer verification is
on automatically when `--ssl-ca` is provided.

## Endpoints

### Instances

| Method   | Path                               | Description                                                          |
|----------|------------------------------------|----------------------------------------------------------------------|
| `GET`    | `/instances`                       | List spawned instances; map of `instance_id` → metadata.             |
| `POST`   | `/instances`                       | Spawn a new instance. **Body**: `spawn_instance.options` -- see below. |
| `POST`   | `/instances/restore`               | Spawn a new instance from a saved scan session. **Body**: `{ "session": "<path or string>" }`. |
| `GET`    | `/instances/:id`                   | Progress envelope (`status`, `busy`, `seed`, `statistics`, `messages`, `errors`). |
| `GET`    | `/instances/:id/summary`           | Same as `:id` minus `statistics` (cheap to poll).                    |
| `GET`    | `/instances/:id/report.crf`        | Cuboid native binary report (use the `Report` Ruby class to parse).  |
| `GET`    | `/instances/:id/report.json`       | Same report as JSON.                                                 |
| `PUT`    | `/instances/:id/scheduler`         | Hand the running instance over to the configured Scheduler.          |
| `PUT`    | `/instances/:id/pause`             | Pause an in-flight scan. Reverse with `/resume`.                     |
| `PUT`    | `/instances/:id/resume`            | Resume a paused scan.                                                |
| `DELETE` | `/instances/:id`                   | Abort + shut down the instance. Idempotent.                          |

#### `POST /instances` body — recommended minimum

```json
{
  "url":     "http://example.com/",
  "checks":  ["*"],
  "audit":   { "elements": ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"] },
  "scope":   { "page_limit": 50 }
}
```

Or copy the
[`spectre://option-presets/quick-scan`](../mcp/index.md#resources)
preset verbatim and substitute the URL. The
[`spectre://option-presets/full-scan`](../mcp/index.md#resources)
preset is the same minus the `scope.page_limit` cap. Full
key-by-key reference is the [Options reference](#options-reference)
below.

### Per-scan service (`/instances/:id/scan/...`)

Spectre-specific scan operations namespaced under each instance.

| Method | Path                                | Description                                         |
|--------|-------------------------------------|-----------------------------------------------------|
| `GET`  | `/instances/:id/scan/progress`      | Issues / sitemap / errors **delta** since this cookie's last poll. |
| `GET`  | `/instances/:id/scan/report.json`   | Final report as JSON (after `status: done`).        |
| `GET`  | `/instances/:id/scan/session`       | `{ "session": "<path>" }` -- snapshot for restore.  |

`/scan/progress` is the workhorse: poll it on a session-cookie-
holding client and the response shrinks to "what's new since you
last asked." Server-side state is keyed by `(cookie,
instance_id)`, so you can fan-poll multiple instances on one
cookie.

### Scheduler

Available only when the server is started with `--scheduler-url
HOST:PORT`; otherwise the routes return `501`.

| Method   | Path                          | Description                                               |
|----------|-------------------------------|-----------------------------------------------------------|
| `GET`    | `/scheduler`                  | Stats + URL.                                              |
| `GET`    | `/scheduler/url`              | The configured Scheduler URL.                             |
| `PUT`    | `/scheduler/url`              | Set / change it. **Body**: `{ "url": "host:port" }`.      |
| `DELETE` | `/scheduler/url`              | Detach.                                                   |
| `GET`    | `/scheduler/running`          | `{ <instance_id>: <info>, ... }` for in-flight scans.     |
| `GET`    | `/scheduler/completed`        | Map of completed scans → report path.                     |
| `GET`    | `/scheduler/failed`           | Map of failed scans → reason.                             |
| `GET`    | `/scheduler/size`             | Pending queue length.                                     |
| `DELETE` | `/scheduler`                  | Clear pending queue.                                      |
| `POST`   | `/scheduler`                  | Push a scan onto the queue. **Body**: same as `POST /instances`. |
| `GET`    | `/scheduler/:instance`        | Info for a queued / running instance.                     |
| `PUT`    | `/scheduler/:instance/detach` | Take an instance back from the Scheduler's care.          |
| `DELETE` | `/scheduler/:instance`        | Remove a still-queued instance.                           |

### Agent

Available only when the server is started with `--agent-url
HOST:PORT`; otherwise `501`.

| Method   | Path         | Description                                          |
|----------|--------------|------------------------------------------------------|
| `GET`    | `/agent/url` | The configured Agent URL.                            |
| `PUT`    | `/agent/url` | Set / change. **Body**: `{ "url": "host:port" }`.    |
| `DELETE` | `/agent/url` | Detach.                                              |

### Grid

| Method   | Path             | Description                                          |
|----------|------------------|------------------------------------------------------|
| `GET`    | `/grid`          | Member list + topology of the configured Agent grid. |
| `GET`    | `/grid/:agent`   | Info for a single member by URL.                     |
| `DELETE` | `/grid/:agent`   | Unplug a member.                                     |

## Options reference

> Same content is served at
> [`spectre://options/reference`](../mcp/index.md#resources) over
> MCP — single source of truth for both surfaces.


The full option surface accepted by `spawn_instance.options`
(over MCP) and by the `POST /instances` body (over REST). Hash,
all keys optional.

The bare engine defaults leave every audit element OFF and every
check unloaded; only `bin/spectre_scan` (and the option presets)
enable them. If you build options from scratch, ship at least
`url`, `audit.elements` (or per-element booleans), and `checks`,
or use `spectre://option-presets/quick-scan`.

### Wire shape

This is what gets POSTed to `/instances` (REST) or sent as
`spawn_instance.options` (MCP) — a single nested JSON object,
all groups optional, every leaf documented further down. Each
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
`POST /instances` (or `spawn_instance` with `start: true`); the
only spawn path where it can be omitted is `start: false` (an
idle instance set up to be configured later).

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
{ "plugins": {} }                         // load nothing extra
{ "plugins": ["defaults/*"] }             // array of names / globs
{ "plugins": { "live": { "url": "..." } } } // hash with per-plugin options
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
  timeout fires, suspend to a snapshot file (loadable later via
  `POST /instances/restore`). Without this the run is aborted.

---


## Quick start

Smallest working flow -- spawn, poll, fetch report, tear down.
Uses `curl` and assumes the server is at `127.0.0.1:7331`.

```bash
# 1. Spawn an instance.
IID=$(curl -sS -c /tmp/cookies -b /tmp/cookies \
    -X POST http://127.0.0.1:7331/instances \
    -H 'Content-Type: application/json' \
    --data '{
        "url":     "http://testfire.net/",
        "checks":  ["*"],
        "audit":   { "elements": ["links","forms","cookies","headers","ui_inputs","ui_forms","jsons","xmls"] },
        "scope":   { "page_limit": 50 }
    }' | jq -r '.id')

# 2. Poll progress (deltas only, thanks to the cookie jar).
while true; do
    PROGRESS=$(curl -sS -c /tmp/cookies -b /tmp/cookies \
        http://127.0.0.1:7331/instances/$IID/scan/progress)
    BUSY=$(curl -sS -c /tmp/cookies -b /tmp/cookies \
        http://127.0.0.1:7331/instances/$IID | jq -r '.busy')
    [ "$BUSY" = "false" ] && break
    sleep 5
done

# 3. Final report.
curl -sS -c /tmp/cookies -b /tmp/cookies \
    http://127.0.0.1:7331/instances/$IID/scan/report.json > report.json

# 4. Tear down.
curl -sS -c /tmp/cookies -b /tmp/cookies \
    -X DELETE http://127.0.0.1:7331/instances/$IID
```

## Client (Ruby)

A minimal Typhoeus-based client. The cookie jar is what makes
`progress` deltas work.

```ruby
require 'json'
require 'tmpdir'
require 'typhoeus'

COOKIES = "#{Dir.tmpdir}/cookiejar.txt"

def request( method, resource, params = nil )
    options = { cookiejar: COOKIES, cookiefile: COOKIES }
    if params
        if method == :get
            options[:params] = params
        else
            options[:body]    = params.to_json
            options[:headers] = { 'Content-Type' => 'application/json' }
        end
    end
    @last = Typhoeus.send(method, "http://127.0.0.1:7331/#{resource}", options)
end

def response_data
    JSON.load(@last.body)
end

# Spawn.
request :post, 'instances', {
    url:     'http://testfire.net/',
    checks:  ['*'],
    audit:   { elements: %w[links forms cookies headers ui_inputs ui_forms jsons xmls] },
    scope:   { page_limit: 50 }
}
iid = response_data['id']

# Poll until done.
loop do
    request :get, "instances/#{iid}/scan/progress"
    pp response_data    # deltas only

    request :get, "instances/#{iid}"
    break if !response_data['busy']

    sleep 1
end

# Report.
request :get, "instances/#{iid}/scan/report.json"
pp response_data

# Tear down.
request :delete, "instances/#{iid}"
```

## Incremental rescans via sessions

`/instances/:id/scan/session` returns the path to a snapshot file
that can be fed back to `POST /instances/restore`. The restored
instance only audits **new** input vectors -- huge speedup on
re-scans of large apps.

```ruby
# 1. First scan, fully audit the target.
request :post, 'instances', {
    url:    'https://ginandjuice.shop/',
    checks: ['*'],
    audit:  { elements: %w[links forms cookies headers ui_inputs ui_forms jsons xmls] }
}
iid = response_data['id']

# Poll-and-report helper (omitted; same as the Quick start example).
monitor_and_report(iid)

# 2. Save the session snapshot path.
request :get, "instances/#{iid}/scan/session"
session = response_data['session']

request :delete, "instances/#{iid}"

# 3. Re-spawn with `instances/restore`. New vectors only this time.
request :post, 'instances/restore', session: session
iid = response_data['id']

monitor_and_report(iid)

request :delete, "instances/#{iid}"
```

## Status semantics

`GET /instances/:id` returns the same lifecycle states the
[MCP surface](../mcp/index.md#status-semantics) advertises:
`ready` → `preparing` → `scanning` → `auditing` → (`paused`/`resumed`) →
`cleanup` → `done` (or `aborted`). `busy` flips to `false` only on
`done`/`aborted`.

## Things to know

- Each spawned instance reserves engine resources up front
  (provisioned cores / RAM / disk). At capacity, `POST /instances`
  returns `503` -- check `/scheduler/size` if you've configured a
  Scheduler so the request is queued instead.
- Sessions are `Rack::Session::Pool` -- in-memory, single-process.
  Fronting Spectre's REST with multiple Pumas behind a load
  balancer requires a shared session store.
- The REST server and the [MCP server](../mcp/index.md) speak to
  the same engine instances. You can spawn over REST and inspect
  via MCP (or vice versa) -- IDs are identical.
