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

## Screenshots

### Sites

#### List
![Sites list](screenshots/Screenshot_20220504_082733.png)
![Sites list](screenshots/Screenshot_20220504_083434.png)

#### Settings
![Sites settings](screenshots/Screenshot_20220504_082801.png)
![Sites settings](screenshots/Screenshot_20220504_082829.png)

#### Scans
![Scans](screenshots/Screenshot_20220504_082949.png)

##### New
![New scan](screenshots/Screenshot_20220504_083006.png)

##### Summary
![Scan summary](screenshots/Screenshot_20220504_083050.png)

##### Issues
![Issues list](screenshots/Screenshot_20220329_123849.png)

##### Coverage
![Scan coverage](screenshots/Screenshot_20220504_083104.png)
![Scan coverage](screenshots/Screenshot_20220504_083509.png)

##### Health
![Scan health](screenshots/Screenshot_20220504_083113.png)

##### Events
![Scan events](screenshots/Screenshot_20220504_083127.png)

###### Issue
![Scan issue](screenshots/Screenshot_20220504_083144.png)
![Scan issue](screenshots/Screenshot_20220504_083154.png)
![Scan issue](screenshots/Screenshot_20220504_083210.png)
![Scan issue](screenshots/Screenshot_20220504_083243.png)
![Scan issue](screenshots/Screenshot_20220504_083304.png)

#### User roles

##### List
![User roles list](screenshots/Screenshot_20220504_082852.png)

##### New
![User roles new](screenshots/Screenshot_20220504_082906.png)
![User roles new](screenshots/Screenshot_20220504_082914.png)
![User roles new](screenshots/Screenshot_20220504_082926.png)
![User roles new](screenshots/Screenshot_20220504_082934.png)

### Profiles

#### List
![Profiles list](screenshots/Screenshot_20220504_083319.png)

#### Show
![Profile show](screenshots/Screenshot_20220504_083330.png)

### Devices

#### List
![Devices list](screenshots/Screenshot_20220504_083347.png)

### Settings
![Settings](screenshots/Screenshot_20220504_083407.png)
