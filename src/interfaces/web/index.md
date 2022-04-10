# Pro (Web UI)

## Installation

### Database connection

Please edit `.system/scnr-ui-pro/config/database.yml` and update it with your
[PostgreSQL](https://www.postgresql.org/) credentials.

### Database setup

```
bin/scnr_pro_task db:create db:migrate db:seed
```

## Boot-up

To boot the Pro interface please issue:

```
bin/scnr_pro
```

After boot-up, you can [visit](http://localhost:9292) the interface via your
browser of choice.

## Features

* Powerful yet intuitive filtering.
* Scheduled/recurring scans support.
  * Simple frequency config support.
  * Cronline frequency config support.
  * Identification of conflicting future scans in calendar.
* Automated issue review.
  * Fixed -- Issues that don't appear in subsequent scans.
  * Regressions -- Fixed issues that re-appeared in subsequent scans.
* Website roles.
  * Form login.
  * Script login.
* Device emulation.
* Scan profiles.
* Extensive scan log.
* Live scan progress.
* Scan coverage display.
* Server/scanner/network health display.
