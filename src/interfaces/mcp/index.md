# MCP

Spectre Scan ships a [Model Context Protocol][mcp] server so that an AI client
(Claude, Cursor, or anything else that speaks MCP) can drive scans directly:
spawn an _Instance_, watch its progress, fetch issues and reports, and tear it
down again — all over a single HTTP endpoint.

It is the same conceptual surface as the [REST API](../rest-api/index.md), but
exposed as MCP _tools_ and described to the client via the protocol's own
`tools/list` discovery.

[mcp]: https://modelcontextprotocol.io/

## Server

To start the MCP server:

```bash
bin/spectre_mcp_server
```

To see MCP server options:

```bash
bin/spectre_mcp_server -h
```

The transport is [Streamable HTTP][http] — every call is a JSON-RPC `POST`,
optionally upgraded to a Server-Sent Events stream by the server. Authentication
is configured in-application (see _Auth_ below); there are no `--username` /
`--password` flags.

[http]: https://modelcontextprotocol.io/docs/concepts/transports#streamable-http

## Routes

The server mounts two trees:

| Path                              | Purpose                                                                  |
|-----------------------------------|--------------------------------------------------------------------------|
| `/mcp`                            | Framework tools — bootstrap _Instances_ without leaving MCP.             |
| `/instances/:instance/scan`       | Scan tools — bound to one running _Instance_.                            |

A typical client flow:

1. `initialize` against `/mcp`, then `tools/call spawn_instance` with the
   scan options. The response carries the `instance_id`.
2. `initialize` against `/instances/<instance_id>/scan` and call the scan tools
   below to drive that instance.
3. When done, `tools/call kill_instance` against `/mcp` to release the slot.

## Tools — framework (`/mcp`)

| Tool              | Arguments                                            | Description                                                                |
|-------------------|------------------------------------------------------|----------------------------------------------------------------------------|
| `list_instances`  | —                                                    | IDs of currently registered _Instances_.                                   |
| `spawn_instance`  | `{ options: <scan options>, start: true }`           | Spawn a new _Instance_ and (optionally) start it. Returns `instance_id`.   |
| `kill_instance`   | `{ instance_id: <id> }`                              | Shut down and unregister an _Instance_.                                    |

The `options` hash is the same shape as the [REST API](../rest-api/index.md)
`POST /instances` body. Unlike the [CLI](./cli.md), MCP does **not** inject any
defaults on top of what you pass in — if you only send
`{ "url": "http://example.com/" }`, the engine will crawl but audit nothing
because no checks are loaded and no audit elements are enabled.

A working minimum is therefore:

```json
{
  "url":    "http://example.com/",
  "checks": ["*"],
  "audit": {
    "links":     true,
    "forms":     true,
    "cookies":   true,
    "headers":   true,
    "ui_inputs": true,
    "ui_forms":  true,
    "jsons":     true,
    "xmls":      true
  }
}
```

- `checks` — array of check names with shell-glob support; `["*"]` loads every
  available check. Single-string `"*"` is **not** equivalent (it won't expand).
- `audit` — element classes the engine is allowed to audit. Anything left out
  here is skipped. The CLI sets these for you; MCP requires them to be explicit.

For the full surface (scope, HTTP, session, plugins, scope rules, etc.) see
the [REST API options reference](../rest-api/index.md#scan-options) — every
field is accepted here verbatim.

Pass `start: false` to register an idle _Instance_ that you'll start later.

## Tools — scan (`/instances/:instance/scan`)

| Tool       | Arguments                                            | Description                                                                                  |
|------------|------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `progress` | `{ issues_since, errors_since, sitemap_since, without_issues, without_errors, without_sitemap, without_statistics }` | Status + statistics + issues + errors + sitemap (mirrors REST `/progress`). Pass back what you've already seen to receive only deltas; opt out of any block with the matching `without_*` flag. All args optional. |
| `report`   | —                                                    | Full report (issues, sitemap, statistics) as JSON.                                           |
| `sitemap`  | `{ from_index: 0 }`                                  | Crawled URLs; pass an offset to page.                                                        |
| `issues`   | `{ without: [<digest>, ...] }`                       | Issues found so far; pass digests already seen to skip them.                                 |
| `errors`   | `{ index: 0 }`                                       | Engine error messages; pass an offset to tail.                                               |
| `pause`    | —                                                    | Pause the running scan.                                                                      |
| `resume`   | —                                                    | Resume a paused scan.                                                                        |
| `abort`    | —                                                    | Abort the scan. Irreversible — use `pause` if you might want to resume.                      |

### Issue digests

Issue `digest` values are unsigned 32-bit `xxh32` integers (e.g.
`3162940604`). Both `issues` and `progress` accept the digest array as
either integers or numeric strings — useful because some JSON-RPC clients
stringify large numbers — and coerce server-side. If you ever see the same
issue stream back unchanged after passing it as `without` / `issues_since`,
a stringified-vs-int mismatch is the first thing to check.

## Auth

Authentication is opt-in and lives on the application class:

```ruby
SCNR::Application.mcp_authenticate_with do |bearer_token|
    User.find_by(api_token: bearer_token)
end
```

When a validator is registered the server requires
`Authorization: Bearer <token>` on every request and returns `401` otherwise.
Without a validator the server accepts unauthenticated traffic — fine for a
loopback bind, dangerous on a public interface.

## Connecting an MCP client

An AI client (Claude Desktop / Code, Cursor, Continue, anything that speaks
MCP) does not need any out-of-band documentation to use the server. The
[protocol itself is self-describing][mcp-tools]: after the `initialize`
handshake the client calls `tools/list` and the server returns each tool's
`name`, `description`, and `inputSchema` (JSON Schema). Whatever you read in
the [Tools — framework](#tools--framework-mcp) and
[Tools — scan](#tools--scan-instancesinstancescan) tables above is exactly
what the model sees in its context, in-band, at decision time. The
descriptions are the docs.

[mcp-tools]: https://modelcontextprotocol.io/docs/concepts/tools

A typical client config looks like:

```jsonc
{
  "mcpServers": {
    "spectre-scan": {
      "url": "http://127.0.0.1:7331/mcp"
    }
  }
}
```

Two caveats specific to this server:

- **Per-instance discovery is manual.** The framework tools at `/mcp`
  (`spawn_instance` / `list_instances` / `kill_instance`) are visible the
  moment the client connects. The scan tools at
  `/instances/<instance_id>/scan` only exist *after* an _Instance_ has been
  spawned, and most MCP clients don't auto-mount new endpoints mid-session.
  Practical patterns: pre-spawn an _Instance_ and put both URLs in the
  client config, or have the AI itself call `spawn_instance` against `/mcp`
  and then ask the user to add the per-_Instance_ URL.

- **Transport is Streamable HTTP.** Many older clients (notably Claude
  Desktop's stdio mode) speak only stdio; for those, drop in any of the
  community stdio↔HTTP MCP bridges. Cursor / Claude Code / Continue speak
  Streamable HTTP natively.

## Example — curl walkthrough

Spawn an _Instance_ targeting `http://testfire.net/` with all checks loaded:

```bash
curl -sS -X POST http://127.0.0.1:7331/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{
    "jsonrpc": "2.0", "id": 1, "method": "initialize",
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": { "name": "curl", "version": "0" }
    }
  }'
```

Take the `Mcp-Session-Id` response header and reuse it on subsequent calls:

```bash
curl -sS -X POST http://127.0.0.1:7331/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Mcp-Session-Id: $SID" \
  --data '{
    "jsonrpc": "2.0", "id": 2, "method": "tools/call",
    "params": {
      "name": "spawn_instance",
      "arguments": {
        "options": {
          "url":    "http://testfire.net/",
          "checks": ["*"],
          "audit":  {
            "links": true, "forms": true, "cookies": true, "headers": true,
            "ui_inputs": true, "ui_forms": true, "jsons": true, "xmls": true
          }
        },
        "start": true
      }
    }
  }'
```

The result body contains the `instance_id`. Switch to the per-_Instance_ route
to poll progress — first call passes empty args to receive a full snapshot
(status, statistics, all issues / errors / sitemap):

```bash
curl -sS -X POST http://127.0.0.1:7331/instances/$INSTANCE_ID/scan \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Mcp-Session-Id: $SID2" \
  --data '{
    "jsonrpc": "2.0", "id": 3, "method": "tools/call",
    "params": { "name": "progress", "arguments": {} }
  }'
```

(Each route mounts its own MCP server, so it gets its own session id from a
fresh `initialize` call.)

For ongoing polling, hand back the digests / offsets you've already
processed and the next response will contain only deltas:

```bash
curl -sS -X POST http://127.0.0.1:7331/instances/$INSTANCE_ID/scan \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Mcp-Session-Id: $SID2" \
  --data '{
    "jsonrpc": "2.0", "id": 4, "method": "tools/call",
    "params": {
      "name": "progress",
      "arguments": {
        "issues_since":       [3162940604, 1457298731],
        "errors_since":       12,
        "sitemap_since":      37,
        "without_statistics": true
      }
    }
  }'
```
