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
