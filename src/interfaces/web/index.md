# Web UI

The WebUI allows you to easily run, manage and schedule scans and their results via an intuitive web interface.

## Boot-up

To boot the Pro interface please run:

```
bin/spectre_pro
```

After boot-up, you can [visit](http://localhost:9292) the interface via your browser of choice.

## Features

### Scan management

- **Quick scan.** A one-input form in the navbar will scan any URL with sane
  defaults — useful for ad-hoc spot checks without leaving the current page.
- **Parallel scans.** Run multiple scans concurrently against the same site,
  different sites, or both — bounded only by configured worker capacity.
- **Recurring scans.** Re-scan the same target on a schedule and get an
  automatic review of every finding compared to the previous revision:
  - **Fixed** — issues that no longer appear.
  - **Regressions** — fixed issues that re-appeared.
  - **New** — first-time findings.
  - **Trusted / untrusted / reviewed / false-positive** — manual states for
    triage that carry forward across revisions.
- **Scheduled scans.** Either pick from preset frequencies (hourly, daily,
  weekly…) or paste a cron expression. The scheduler surfaces upcoming
  occurrences and flags conflicts (overlapping start times, parallelism
  ceiling) before they fire.
- **Suspend / resume / repeat.** Pause a long-running scan and resume from
  the same on-disk session later. One-click repeat re-runs a finished scan
  with the exact same configuration.

### Live monitoring

- **Real-time progress.** Coverage, request rate, discovered pages and
  newly-found issues stream into the UI over Action Cable as the scan
  runs — no manual refresh.
- **Live event-driven cache busts.** Per-user dashboard / navbar caches
  invalidate the moment a model commits, so counts and badges stay
  truthful without polling.
- **Scan, revision and site live views.** Drill in at the level you need:
  whole-site activity, a specific scan or a single revision.

### Findings & analysis

- **Issue detail with proof, remediation and exploit.** Every finding is
  presented with the captured request / response, normalised proof, a
  per-check remediation guide and (when available) a working exploit
  payload.
- **DOM-XSS introspector.** For DOM-level findings, follow the data flow
  from source to sink across the rendered page with captured stack frames
  and the page snapshot inline.
- **Coverage explorer.** Every page the scanner reached, with HTTP
  status, content-type and a one-click jump to the issues attached to it.
- **Powerful filtering.** Stack severity / state / type / scan / revision
  filters; narrow by site, by check, by URL pattern; permalinks survive
  reload and live-refresh.
- **Severity-aware sorting.** High-impact findings always float to the
  top, with sibling-grouping so duplicate signatures collapse cleanly.

### Configuration

- **Scan profiles.** Reusable bundles of checks, scope rules,
  audit options and plug-ins. Per-user, per-site or shared.
- **Per-site overrides.** Override profile scope rules at the site level
  without forking a whole profile.
- **Device emulation.** Scan as a desktop browser, mobile, tablet, or
  any custom user-agent / viewport / touch combination.
- **Site user roles.** Authenticate the scanner as one or more
  application personas:
  - **Form login** — declarative URL + form parameters.
  - **Script login** — drop in Ruby with a prepared browser driver
    (Watir) or HTTP client.
  - Each role gets its own captured session that persists across
    revisions.

### Operations & audit

- **Server / scanner / network health.** Request rate, response times,
  browser-pool utilisation, error counts, queue depth — surfaced in
  charts that update live.
- **Full audit log.** Every change to sites, scans, revisions, issues
  and user roles is captured (PaperTrail) with the actor, the diff
  and a click-through to the affected object — even after the object
  itself has been deleted.
- **Resilient scheduler.** SQLite writer-lock contention, autoloader
  races and transient RPC errors are handled internally; the UI stays
  responsive while two or more scans hammer the database.

### Reporting & integrations

- **Multi-format export.** HTML, JSON, XML, plain-text and the
  framework-native AFR archive — at the scan, revision or filtered
  result-set level.
- **Notifications.** Per-event email / browser push for scan
  start / finish / failure / suspension and severity thresholds.
- **OpenAI assist.** Optional LLM-backed remediation expansion for
  individual findings (configurable in Settings).

### Quality of life

- **Light & dark themes** with a one-click toggle that persists across
  sessions and respects `prefers-color-scheme` on first visit.
- **Per-page UI state persistence.** Severity-section open/closed,
  collapsed details, table sort and filter selections are remembered
  per browser without server round-trips.
- **Keyboard-friendly forms** and focus-aware live-refresh: an open
  `<select>` or focused input is never swapped out from under you.
- **First-run welcome.** A guided empty-state experience walks new
  installs from "no sites yet" to "scanning" without docs.

## Screenshots

### Welcome

The first-run experience: an empty-state landing page with a quick-scan
form and a path to add your first site.

![Welcome screen](screenshots/spectre-welcome.png)

### Dashboard

The dashboard is the home page once you have at least one site. It
surfaces running scans, recent activity, aggregate counts and per-site
health at a glance.

#### Light theme

![Dashboard — light theme](screenshots/spectre-light-dashboard.png)

#### Dark theme

![Dashboard — dark theme](screenshots/spectre-dashboard.png)

#### Continued view

Tiles below the fold show recent revisions, performance trends and
per-site rollups.

![Dashboard — continued](screenshots/spectre-dashboard-2.png)

#### Sub-dashboard: by severity

A focused view that breaks every issue down by severity (high / medium
/ low / informational), with click-through to the matching issue list.

![Dashboard — by severity](screenshots/spectre-dashboard-by-severity.png)

#### Sub-dashboard: by issue type

Rolls every issue up by check / type so you can see at a glance which
weakness families dominate the picture.

![Dashboard — by issue type](screenshots/spectre-dashboard-by-issue-type.png)

### Sites

Add and manage the sites you wish to scan. Each site keeps its own
profiles, devices, user roles, scans and audit history.

#### All sites

![Sites index](screenshots/spectre-sites.png)

#### Site overview

The per-site landing page — a snapshot of recent revisions, severity
rollup and currently-running activity for that one site.

![Site overview](screenshots/spectre-overview.png)

#### Site live status

Live progress for the site's currently-running scan, updated in
real-time over Action Cable.

![Site — live](screenshots/spectre-site-live.png)

#### Site scans

The full scan list for a site, grouped by Active / Suspended /
Finished / Schedule.

![Site scans](screenshots/spectre-site-scans.png)

#### Site settings

Per-site knobs: protocol, host, port, default profile, default device
and inherited scope rules.

![Site settings](screenshots/spectre-site-settings.png)

#### User roles

Manage authenticated personas the scanner can assume — handy for
testing role-gated parts of the application.

![Site user roles](screenshots/spectre-site-user-role.png)

##### Script-based login

When form-based login isn't enough, drop in a Ruby snippet using a
prepared browser driver or HTTP client.

![Site user role — login script](screenshots/spectre-site-user-role-login-script.png)

### Scans

Configure, schedule, monitor and re-run scans.

#### Quick scan

The navbar's quick-scan widget — one URL away from a default-profile
scan against a brand-new or existing site.

![Quick scan](screenshots/spectre-quick-scan.png)

#### New scan

The full configuration form: profile, device, role, schedule, custom
scope, plug-ins.

![New scan](screenshots/spectre-new-scan.png)

#### Scan live

Live scan progress at the scan level — running revision, queue stats,
discovered pages, issues found so far.

![Scan — live](screenshots/spectre-scan-live.png)

#### Generic live view

Live status surface used both for site-wide and scan-wide live
monitoring.

![Live status](screenshots/spectre-live.png)

### Revisions

Each scan produces revisions — incremental snapshots of the same
target. Revisions are where issues, coverage and reports actually
live.

#### Revision — live

Live monitoring of an individual revision while it scans.

![Revision — live](screenshots/spectre-revision-live.png)

#### Revision — issues

The issue listing for a single revision, with severity / state /
type filters.

![Revision — issues](screenshots/spectre-revision-issues.png)

### Issues

Drill into individual findings — proof, remediation guidance,
exploit, request/response capture, dissected payloads.

#### Issue detail

![Issue — overview](screenshots/spectre-issue-1.png)

![Issue — proof / response](screenshots/spectre-issue-2.png)

![Issue — remediation](screenshots/spectre-issue-3.png)

#### DOM XSS

DOM-XSS issue with the **introspector** view that traces the data flow
from source to sink across the rendered page.

![Issue — DOM XSS](screenshots/spectre-issue-domxss.png)

#### Recurring scans — regressions & fixes

Recurring scans automatically diff their findings across revisions:
fixed issues drop out, regressions get flagged, new findings get
their own state.

![Recurring scan — review (1)](screenshots/spectre-issue-rs-1.png)

![Recurring scan — review (2)](screenshots/spectre-issue-rs-2.png)

![Recurring scan — review (3)](screenshots/spectre-issue-rs-3.png)

### Introspector

A dedicated view for server-side findings: source → sink data-flow
trace, captured stack frames and the rendered page snapshot.

![Introspector — flow (1)](screenshots/spectre-introspector-1.png)

![Introspector — flow (2)](screenshots/spectre-introspector-2.png)

![Introspector — flow (3)](screenshots/spectre-introspector-3.png)

![Introspector — flow (4)](screenshots/spectre-introspector-4.png)

### Coverage

Every page the scanner reached, with HTTP status, content-type and a
click-through to the issues that came out of each one.

![Coverage](screenshots/spectre-coverage.png)

### Health

Server / scanner / network health — request rate, response times,
browser-pool utilisation, error counts.

![Health](screenshots/spectre-health.png)

### Logs

A full audit log of every change to sites, scans, revisions, issues
and user roles. Filterable by event, object type and actor.

![Logs](screenshots/spectre-logs.png)

### Profiles

Reusable scan configurations: which checks to run, scope rules,
plug-ins, audit options.

#### All profiles

![Profiles](screenshots/spectre-profiles.png)

#### Profile editor — checks

Pick exactly which checks should run as part of a profile.

![Profile — all checks](screenshots/spectre-profile-all-checks.png)

### Devices

Device emulation lets you scan as a desktop browser, mobile, tablet,
or any custom user-agent / viewport combination.

![Devices](screenshots/spectre-device-spectre.png)

### Settings

Top-level application settings: notifications, OpenAI integration,
default scan / HTTP / browser-pool tuning.

![Settings](screenshots/spectre-settings.png)

### Export

Export scan results in any of the supported report formats (HTML,
JSON, XML, plain-text, AFR archive).

![Export](screenshots/spectre-export.png)
