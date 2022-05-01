# Pro (Web UI)

The Pro interface allows you to easily run, manage and schedule scans and their 
results via an intuitive web interface.

## DB configuration and setup

Prior to using the Pro interface please make sure that a PostgreSQL server is
available and that a DB connection can be successfully established.

For more information please refer to the [Installation](../../installation.md) page.

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
